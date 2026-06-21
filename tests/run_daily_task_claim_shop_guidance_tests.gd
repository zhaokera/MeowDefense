extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_daily_task_claim_shop_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/daily_task_claim_shop_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/daily_task_claim_shop_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/daily_task_claim_shop_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "daily task claim shop guidance should keep an Image2 full-screen reward reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "daily task claim shop guidance should keep an Image2-derived badge source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "daily task claim shop guidance should use a transparent runtime badge")
	_assert_manifest_entry("daily_task_claim_shop_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("daily_task_claim_shop_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("daily_task_claim_shop_guidance_badge", GUIDANCE_BADGE_PATH)

	await _assert_small_task_reward_keeps_plain_claim_overlay()
	await _assert_claim_reward_routes_to_affordable_yarn_purchase()
	_finish()


func _assert_small_task_reward_keeps_plain_claim_overlay() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_total_fish", 0)
	instance.set("_yarn_traps", 1)
	var task_button: Button = _assert_button(instance, "DailyTaskButton", "small reward path should expose daily task entry")
	if task_button != null:
		task_button.emit_signal("pressed")
		await process_frame
	var claim: Button = _assert_button(instance, "ClaimDailyTaskYarnButton", "small reward path should expose yarn task claim")
	if claim != null:
		claim.emit_signal("pressed")
		await process_frame
		await process_frame
	_assert_true(int(instance.get("_total_fish")) == 15, "small yarn task reward should grant fish")
	_assert_exists(instance, "DailyTaskClaimRewardOverlay", "small daily task reward should show the claim overlay")
	_assert_missing(instance, "DailyTaskClaimShopGuidance", "small daily task reward should not route to shop")
	_assert_missing(instance, "DailyTaskShopReturnGuidance", "small normal task reward should not show shortage-return guidance")
	_cleanup_instance(instance)


func _assert_claim_reward_routes_to_affordable_yarn_purchase() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_total_fish", 0)
	instance.set("_yarn_traps", 0)
	instance.set("_best_stars_by_level", {1: 3})
	instance.call("_recalculate_best_stars")

	var task_button: Button = _assert_button(instance, "DailyTaskButton", "threshold reward path should expose daily task entry")
	if task_button != null:
		task_button.emit_signal("pressed")
		await process_frame
	var claim: Button = _assert_button(instance, "ClaimDailyTaskFirstClearButton", "threshold reward path should expose first-clear claim")
	if claim != null:
		_assert_true(not claim.disabled, "first-clear task should be claimable")
		claim.emit_signal("pressed")
		await process_frame
		await process_frame

	_assert_true(int(instance.get("_total_fish")) == 30, "first-clear daily task reward should make yarn affordable")
	var reward: Control = _assert_control(instance, "DailyTaskClaimRewardOverlay", "threshold daily task reward should show claim overlay")
	var guidance: Control = _assert_control(instance, "DailyTaskClaimShopGuidance", "threshold daily task reward should show shop guidance")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_daily_task_claim_shop_guidance", false)), "daily task claim shop guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "daily task claim shop guidance should not block its route button")
	_assert_missing(instance, "DailyTaskShopReturnGuidance", "normal threshold reward should not reuse shortage-return guidance")
	var badge: TextureRect = _assert_texture_node(instance, "DailyTaskClaimShopBadge", GUIDANCE_BADGE_PATH, "daily task claim shop guidance should show the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "daily task claim shop badge should not block route button")
	var label: Label = _assert_label(instance, "DailyTaskClaimShopLabel", "daily task claim shop guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("商店") or label.text.contains("毛线"), "daily task claim shop copy should point to shop spending")
	var route_button: Button = _assert_button(instance, "DailyTaskClaimShopButton", "daily task claim shop guidance should expose a shop route")
	if reward != null and route_button != null:
		route_button.emit_signal("pressed")
		_assert_true(bool(reward.get_meta("image2_overlay_exit_animation", false)), "daily task claim shop route should animate the Image2 reward overlay out")
		_assert_true(route_button.disabled, "daily task claim shop route should disable while routing")
		_assert_missing(instance, "ShopOverlay", "daily task claim shop route should not hard-cut before reward exit")
		await _wait_until_missing(instance, "DailyTaskClaimRewardOverlay")
		await _wait_until_exists(instance, "ShopOverlay")

	_assert_exists(instance, "ShopOverlay", "daily task claim shop route should open shop")
	_assert_missing(instance, "DailyTaskOverlay", "daily task claim shop route should leave daily tasks")
	var yarn_buy: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "shop should expose yarn purchase after daily task claim guidance")
	if yarn_buy != null:
		_assert_true(not yarn_buy.disabled, "daily task reward should make yarn purchase affordable")
		_assert_true(bool(yarn_buy.get_meta("image2_daily_task_claim_shop_target", false)), "daily task claim route should mark yarn buy button as the guided target")
	var yarn_frame: Control = _assert_control(instance, "ShopYarnTrapKitBuyButtonFrame", "shop should show the yarn buy plate after daily task claim guidance")
	if yarn_frame != null:
		_assert_true(bool(yarn_frame.get_meta("image2_daily_task_claim_shop_target", false)), "daily task claim route should mark yarn buy plate as the guided target")
	_assert_true(int(instance.get("_total_fish")) == 30, "routing to shop should preserve earned task fish")
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
		print("DAILY TASK CLAIM SHOP GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("DAILY TASK CLAIM SHOP GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear daily task claim shop guidance test save: %s" % error)
