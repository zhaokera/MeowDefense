extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_shop_paw_purchase_achievement_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/shop_paw_purchase_achievement_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/shop_paw_purchase_achievement_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/shop_paw_purchase_achievement_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "shop paw purchase should keep an Image2 full-screen achievement guidance reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "shop paw purchase should keep an Image2-derived guidance source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "shop paw purchase should use a transparent runtime achievement guidance badge")
	_assert_manifest_entry("shop_paw_purchase_achievement_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("shop_paw_purchase_achievement_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("shop_paw_purchase_achievement_guidance_badge", GUIDANCE_BADGE_PATH)

	var yarn_instance: Node = await _new_instance()
	if yarn_instance != null:
		yarn_instance.set("_total_fish", 40)
		yarn_instance.call("_show_shop_overlay", yarn_instance.find_child("MainMenuScreen", true, false))
		await process_frame
		var yarn_button: Button = _assert_button(yarn_instance, "BuyShopYarnTrapKitButton", "yarn guard should expose yarn buy button")
		if yarn_button != null:
			yarn_button.emit_signal("pressed")
			await process_frame
		_assert_exists(yarn_instance, "ShopPurchaseRewardOverlay", "yarn purchase should still show purchase reward")
		_assert_missing(yarn_instance, "ShopPawPurchaseAchievementGuidance", "non-paw purchases should not show paw achievement guidance")
		_cleanup_instance(yarn_instance)

	var instance: Node = await _new_instance()
	if instance == null:
		_finish()
		return
	instance.set("_total_fish", 60)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var buy_button: Button = _assert_button(instance, "BuyShopPawBundleButton", "paw bundle should expose a buy button")
	if buy_button != null:
		buy_button.emit_signal("pressed")
		await process_frame
		await process_frame

	_assert_true(int(instance.get("_total_fish")) == 15, "buying paw bundle should spend fish before guidance")
	_assert_true(int(instance.get("_paw_tokens")) == 2, "buying paw bundle should add paw tokens before guidance")
	var overlay: Control = _assert_control(instance, "ShopPurchaseRewardOverlay", "paw purchase should open purchase reward overlay")
	var guidance: Control = _assert_control(instance, "ShopPawPurchaseAchievementGuidance", "paw purchase should show achievement guidance")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_shop_paw_purchase_achievement_guidance", false)), "paw purchase achievement guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "paw purchase achievement guidance group should not block its route button")
	var badge: TextureRect = _assert_texture_node(instance, "ShopPawPurchaseAchievementBadge", GUIDANCE_BADGE_PATH, "paw purchase guidance should show the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "paw purchase guidance badge should not block route button")
	var label: Label = _assert_label(instance, "ShopPawPurchaseAchievementLabel", "paw purchase guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("成就") or label.text.contains("徽章"), "paw purchase guidance should point to achievements or badges")
	var route_button: Button = _assert_button(instance, "ShopPawPurchaseAchievementButton", "paw purchase guidance should expose an achievements route button")
	if overlay != null and route_button != null:
		route_button.emit_signal("pressed")
		_assert_true(bool(overlay.get_meta("image2_overlay_exit_animation", false)), "paw purchase achievement route should animate the Image2 purchase overlay out")
		_assert_true(route_button.disabled, "paw purchase achievement route should disable while routing")
		_assert_missing(instance, "AchievementsOverlay", "paw purchase achievement route should not hard-cut before purchase exit")
		await _wait_until_missing(instance, "ShopPurchaseRewardOverlay")
		await _wait_until_exists(instance, "AchievementsOverlay")

	_assert_exists(instance, "AchievementsOverlay", "paw purchase achievement route should open achievements")
	_assert_exists(instance, "AchievementsActionButton", "achievements overlay should remain actionable after routing")
	_assert_true(int(instance.get("_paw_tokens")) == 2, "routing to achievements should preserve purchased paw tokens")
	_assert_true(int(instance.get("_total_fish")) == 15, "routing to achievements should preserve remaining fish")

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
	instance.set("_reward_date_override", "2026-06-20")
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
		print("SHOP PAW PURCHASE ACHIEVEMENT GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SHOP PAW PURCHASE ACHIEVEMENT GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear shop paw purchase achievement guidance test save: %s" % error)
