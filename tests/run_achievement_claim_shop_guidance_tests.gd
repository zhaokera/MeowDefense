extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_achievement_claim_shop_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/achievement_claim_shop_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/achievement_claim_shop_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/achievement_claim_shop_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "achievement claim should keep an Image2 full-screen shop guidance reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "achievement claim should keep an Image2-derived shop guidance source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "achievement claim should use a transparent runtime shop guidance badge")
	_assert_manifest_entry("achievement_claim_shop_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("achievement_claim_shop_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("achievement_claim_shop_guidance_badge", GUIDANCE_BADGE_PATH)

	var shop_instance: Node = await _new_instance()
	if shop_instance != null:
		shop_instance.set("_total_fish", 60)
		shop_instance.call("_show_shop_overlay", shop_instance.find_child("MainMenuScreen", true, false))
		await process_frame
		var paw_button: Button = _assert_button(shop_instance, "BuyShopPawBundleButton", "shop guard should expose paw bundle buy button")
		if paw_button != null:
			paw_button.emit_signal("pressed")
			await process_frame
		_assert_exists(shop_instance, "ShopPurchaseRewardOverlay", "shop purchase should still show purchase reward")
		_assert_missing(shop_instance, "AchievementClaimShopGuidance", "shop purchase rewards should not show achievement-claim shop guidance")
		_cleanup_instance(shop_instance)

	var instance: Node = await _new_instance()
	if instance == null:
		_finish()
		return
	instance.set("_best_stars_by_level", {1: 3})
	instance.call("_recalculate_best_stars")
	instance.call("_show_achievements_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var claim_button: Button = _assert_button(instance, "AchievementFirstClearClaimButton", "completed achievement should expose a claim button")
	if claim_button != null:
		claim_button.emit_signal("pressed")
		await process_frame
		await process_frame

	_assert_true(int(instance.get("_total_fish")) == 10, "achievement claim should grant fish before shop guidance")
	_assert_true(int(instance.get("_paw_tokens")) == 1, "achievement claim should grant paw tokens before shop guidance")
	var overlay: Control = _assert_control(instance, "AchievementClaimRewardOverlay", "achievement claim should open reward overlay")
	var guidance: Control = _assert_control(instance, "AchievementClaimShopGuidance", "achievement claim reward should show shop guidance")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_achievement_claim_shop_guidance", false)), "achievement claim shop guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "achievement claim shop guidance group should not block its route button")
	var badge: TextureRect = _assert_texture_node(instance, "AchievementClaimShopBadge", GUIDANCE_BADGE_PATH, "achievement claim shop guidance should show the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "achievement claim shop guidance badge should not block route button")
	var label: Label = _assert_label(instance, "AchievementClaimShopLabel", "achievement claim shop guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("商店") or label.text.contains("购买"), "achievement claim shop guidance should point to shop spending")
	var route_button: Button = _assert_button(instance, "AchievementClaimShopButton", "achievement claim shop guidance should expose a shop route button")
	if overlay != null and route_button != null:
		route_button.emit_signal("pressed")
		_assert_true(bool(overlay.get_meta("image2_overlay_exit_animation", false)), "achievement claim shop route should animate the Image2 reward overlay out")
		_assert_true(route_button.disabled, "achievement claim shop route should disable while routing")
		_assert_missing(instance, "ShopOverlay", "achievement claim shop route should not hard-cut before reward exit")
		await _wait_until_missing(instance, "AchievementClaimRewardOverlay")
		await _wait_until_exists(instance, "ShopOverlay")

	_assert_exists(instance, "ShopOverlay", "achievement claim shop route should open shop")
	_assert_exists(instance, "BuyShopYarnTrapKitButton", "shop should be actionable after achievement claim routing")
	_assert_true(int(instance.get("_total_fish")) == 10, "routing to shop should preserve claimed fish")
	_assert_true(int(instance.get("_paw_tokens")) == 1, "routing to shop should preserve claimed paw token")
	_assert_missing(instance, "AchievementsOverlay", "routing to shop should close achievements overlay")

	_cleanup_instance(instance)
	_finish()


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
		print("ACHIEVEMENT CLAIM SHOP GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ACHIEVEMENT CLAIM SHOP GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear achievement claim shop guidance test save: %s" % error)
