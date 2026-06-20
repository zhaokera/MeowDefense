extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_result_reward_shop_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/result_reward_shop_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/result_reward_shop_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/result_reward_shop_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "result reward shop guidance should keep an Image2 full-screen design reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "result reward shop guidance should keep an Image2-derived badge source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "result reward shop guidance should use a transparent runtime badge")
	_assert_manifest_entry("result_reward_shop_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("result_reward_shop_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("result_reward_shop_guidance_badge", GUIDANCE_BADGE_PATH)

	await _assert_victory_reward_routes_to_shop_when_no_achievement_is_pending()
	await _assert_claimable_achievement_result_keeps_achievement_guidance_priority()
	await _assert_new_level_unlock_keeps_unlock_feedback_priority()
	await _assert_defeat_result_has_no_reward_shop_guidance()
	await _assert_zero_reward_result_has_no_shop_guidance()
	_finish()


func _assert_victory_reward_routes_to_shop_when_no_achievement_is_pending() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_claimed_achievements", {"first_clear": true})
	instance.set("_current_level_id", 1)
	instance.set("_unlocked_level", 2)
	instance.call("_show_result", true, 3, 35)
	await process_frame
	await process_frame

	var screen: Control = _assert_control(instance, "ResultScreen", "victory result should open before shop guidance")
	_assert_missing(instance, "ResultAchievementClaimGuidance", "claimed achievement state should not show result achievement guidance")
	var guidance: Control = _assert_control(instance, "ResultRewardShopGuidance", "victory result should show shop guidance when fish was earned")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_result_reward_shop_guidance", false)), "result reward shop guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "result reward shop guidance group should not block its route button")
	var badge: TextureRect = _assert_texture_node(instance, "ResultRewardShopGuidanceBadge", GUIDANCE_BADGE_PATH, "result reward shop guidance should render the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "result reward shop guidance badge should not block route button")
	var label: Label = _assert_label(instance, "ResultRewardShopGuidanceLabel", "result reward shop guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("商店") or label.text.contains("购买"), "result reward shop guidance should point to shop spending")
	var route_button: Button = _assert_button(instance, "ResultRewardShopGuidanceButton", "result reward shop guidance should expose a shop route")
	if screen != null and route_button != null:
		route_button.emit_signal("pressed")
		_assert_true(bool(screen.get_meta("image2_result_exit_animation", false)), "result reward shop route should animate the Image2 result screen out")
		_assert_true(route_button.disabled, "result reward shop route should disable while routing")
		_assert_missing(instance, "ShopOverlay", "result reward shop route should not hard-cut before result exit")
		await _wait_until_missing(instance, "ResultScreen")
		await _wait_until_exists(instance, "ShopOverlay")

	_assert_exists(instance, "ShopOverlay", "result reward shop route should open the shop")
	_assert_exists(instance, "ClaimShopFishPackButton", "shop should expose starter fish pack after result routing")
	var yarn_buy: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "shop should expose yarn trap purchase after result routing")
	if yarn_buy != null:
		_assert_true(not yarn_buy.disabled, "earned victory fish should make yarn trap purchase affordable")
	_assert_true(int(instance.get("_total_fish")) == 35, "routing to shop should preserve victory fish reward")
	_cleanup_instance(instance)


func _assert_new_level_unlock_keeps_unlock_feedback_priority() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_claimed_achievements", {"first_clear": true})
	instance.set("_current_level_id", 1)
	instance.set("_unlocked_level", 1)
	instance.call("_show_result", true, 3, 35)
	await process_frame
	_assert_exists(instance, "ResultNextLevelUnlockFeedback", "newly unlocked levels should keep next-level feedback priority")
	_assert_missing(instance, "ResultRewardShopGuidance", "shop guidance should not stack over new-level unlock feedback")
	_cleanup_instance(instance)


func _assert_claimable_achievement_result_keeps_achievement_guidance_priority() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_current_level_id", 1)
	instance.set("_unlocked_level", 1)
	instance.call("_show_result", true, 3, 35)
	await process_frame
	_assert_exists(instance, "ResultAchievementClaimGuidance", "claimable achievements should keep result achievement guidance priority")
	_assert_missing(instance, "ResultRewardShopGuidance", "shop guidance should not stack over claimable achievement guidance")
	_cleanup_instance(instance)


func _assert_defeat_result_has_no_reward_shop_guidance() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.call("_show_result", false, 0, 0)
	await process_frame
	_assert_missing(instance, "ResultRewardShopGuidance", "defeat result should not show reward shop guidance")
	_cleanup_instance(instance)


func _assert_zero_reward_result_has_no_shop_guidance() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_claimed_achievements", {"first_clear": true})
	instance.call("_show_result", true, 3, 0)
	await process_frame
	_assert_missing(instance, "ResultRewardShopGuidance", "zero-fish victory result should not show shop guidance")
	_cleanup_instance(instance)


func _new_instance() -> Node:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		return null
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame
	return instance


func _cleanup_instance(instance: Node) -> void:
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	await process_frame
	_clear_save_file()


func _assert_manifest_entry(entry_id: String, expected_path: String) -> void:
	if not FileAccess.file_exists(MANIFEST_PATH):
		_failures.append("assets manifest should exist")
		return
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		_failures.append("assets manifest should be readable")
		return
	var data: Variant = JSON.parse_string(file.get_as_text())
	if not data is Dictionary:
		_failures.append("assets manifest should be a JSON object")
		return
	var entries: Array = (data as Dictionary).get("ui", []) as Array
	for entry: Variant in entries:
		if entry is Dictionary and str(entry.get("id", "")) == entry_id:
			_assert_true(str(entry.get("path", "")) == expected_path, "%s should point at %s" % [entry_id, expected_path])
			return
	_failures.append("assets manifest should include %s" % entry_id)


func _assert_file_exists(path: String, message: String) -> void:
	if not FileAccess.file_exists(path):
		_failures.append(message)


func _assert_texture_node(root_node: Node, node_name: String, expected_path: String, message: String) -> TextureRect:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if not node is TextureRect:
		_failures.append("%s should be a TextureRect" % node_name)
		return null
	var texture_rect: TextureRect = node as TextureRect
	_assert_true(texture_rect.texture != null, "%s should have a texture" % node_name)
	if texture_rect.texture != null:
		_assert_true(texture_rect.texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])
	return texture_rect


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
	return null


func _assert_label(root_node: Node, node_name: String, message: String) -> Label:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Label:
		return node as Label
	_failures.append("%s should be a Label" % node_name)
	return null


func _assert_control(root_node: Node, node_name: String, message: String) -> Control:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Control:
		return node as Control
	_failures.append("%s should be a Control" % node_name)
	return null


func _assert_exists(root_node: Node, node_name: String, message: String) -> Node:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
	return node


func _assert_missing(root_node: Node, node_name: String, message: String) -> void:
	if _find_by_name(root_node, node_name) != null:
		_failures.append(message)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _find_by_name(node: Node, node_name: String) -> Node:
	if node == null:
		return null
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) != null:
			return
		await process_frame


func _wait_until_missing(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) == null:
			return
		await process_frame


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("RESULT REWARD SHOP GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("RESULT REWARD SHOP GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear result reward shop guidance test save: %s" % error)
