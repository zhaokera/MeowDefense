extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_backpack_organize_shop_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/backpack_organize_shop_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/backpack_organize_shop_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/backpack_organize_shop_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "backpack organize reward should keep an Image2 full-screen shop guidance reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "backpack organize reward should keep an Image2-derived shop guidance source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "backpack organize reward should use a transparent runtime shop guidance badge")
	_assert_manifest_entry("backpack_organize_shop_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("backpack_organize_shop_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("backpack_organize_shop_guidance_badge", GUIDANCE_BADGE_PATH)

	await _assert_small_organize_reward_does_not_show_shop_guidance()
	await _assert_organize_reward_routes_to_affordable_yarn_purchase()
	_finish()


func _assert_small_organize_reward_does_not_show_shop_guidance() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_total_fish", 10)
	instance.set("_backpack_organized", false)
	instance.call("_show_backpack_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var organize_button: Button = _assert_button(instance, "OrganizeBackpackButton", "backpack should expose organize action")
	if organize_button != null:
		organize_button.emit_signal("pressed")
		await process_frame
		await process_frame
	_assert_true(int(instance.get("_total_fish")) == 15, "small organize reward should still grant five fish")
	_assert_exists(instance, "BackpackOrganizeRewardOverlay", "small organize reward should still show reward overlay")
	_assert_missing(instance, "BackpackOrganizeShopGuidance", "organize rewards that do not make yarn affordable should not show shop guidance")
	_cleanup_instance(instance)


func _assert_organize_reward_routes_to_affordable_yarn_purchase() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_total_fish", 20)
	instance.set("_yarn_traps", 0)
	instance.set("_backpack_organized", false)
	instance.call("_show_backpack_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var organize_button: Button = _assert_button(instance, "OrganizeBackpackButton", "backpack should expose organize action for yarn-threshold reward")
	if organize_button != null:
		organize_button.emit_signal("pressed")
		await process_frame
		await process_frame

	_assert_true(int(instance.get("_total_fish")) == 25, "organize reward should raise total fish to yarn price")
	var reward: Control = _assert_control(instance, "BackpackOrganizeRewardOverlay", "organize reward should show reward overlay")
	var guidance: Control = _assert_control(instance, "BackpackOrganizeShopGuidance", "organize reward should show shop guidance when yarn becomes affordable")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_backpack_organize_shop_guidance", false)), "backpack organize shop guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "backpack organize shop guidance group should not block its route button")
	var badge: TextureRect = _assert_texture_node(instance, "BackpackOrganizeShopBadge", GUIDANCE_BADGE_PATH, "backpack organize shop guidance should show the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "backpack organize shop guidance badge should not block route button")
	var label: Label = _assert_label(instance, "BackpackOrganizeShopLabel", "backpack organize shop guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("商店") or label.text.contains("毛线"), "backpack organize shop guidance should point to shop spending")
	var route_button: Button = _assert_button(instance, "BackpackOrganizeShopButton", "backpack organize shop guidance should expose a shop route")
	if reward != null and route_button != null:
		route_button.emit_signal("pressed")
		_assert_true(bool(reward.get_meta("image2_overlay_exit_animation", false)), "backpack organize shop route should animate the Image2 reward overlay out")
		_assert_true(route_button.disabled, "backpack organize shop route should disable while routing")
		await _wait_until_missing(instance, "BackpackOrganizeRewardOverlay")

	_assert_exists(instance, "ShopOverlay", "backpack organize shop route should open the shop")
	_assert_missing(instance, "BackpackOverlay", "backpack organize shop route should leave the backpack overlay")
	var yarn_button: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "shop should expose yarn purchase after backpack organize guidance")
	if yarn_button != null:
		_assert_true(not yarn_button.disabled, "organized fish reward should make yarn purchase affordable")
		_assert_true(bool(yarn_button.get_meta("image2_backpack_organize_shop_target", false)), "backpack organize route should mark yarn buy button as the guided target")
	var yarn_frame: TextureRect = _assert_texture_node(instance, "ShopYarnTrapKitBuyButtonFrame", "res://assets/generated/ui/shop_product_buy_button_plate.png", "backpack organize route should show the Image2 yarn buy plate")
	if yarn_frame != null:
		_assert_true(bool(yarn_frame.get_meta("image2_backpack_organize_shop_target", false)), "backpack organize route should mark yarn buy plate as the guided target")
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


func _wait_until_missing(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) == null:
			return
		await process_frame


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("BACKPACK ORGANIZE SHOP GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BACKPACK ORGANIZE SHOP GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear backpack organize shop guidance test save: %s" % error)
