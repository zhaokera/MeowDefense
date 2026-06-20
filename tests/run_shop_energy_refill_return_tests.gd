extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_shop_energy_refill_return_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const RETURN_REFERENCE_PATH := "res://assets/generated/ui/shop_energy_refill_return_design_reference.png"
const RETURN_SOURCE_PATH := "res://assets/generated/ui/shop_energy_refill_return_badge_source.png"
const RETURN_BADGE_PATH := "res://assets/generated/ui/shop_energy_refill_return_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(RETURN_REFERENCE_PATH, "shop energy refill return should have a project-bound Image2 design reference")
	_assert_file_exists(RETURN_SOURCE_PATH, "shop energy refill return should keep its Image2-derived source asset")
	_assert_file_exists(RETURN_BADGE_PATH, "shop energy refill return should have a transparent runtime badge")
	_assert_manifest_entry("shop_energy_refill_return_design_reference", RETURN_REFERENCE_PATH)
	_assert_manifest_entry("shop_energy_refill_return_badge_source", RETURN_SOURCE_PATH)
	_assert_manifest_entry("shop_energy_refill_return_badge", RETURN_BADGE_PATH)

	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish()
		return

	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	instance.set("_reward_date_override", "2026-06-15")
	root.add_child(instance)
	await process_frame

	instance.set("_total_fish", 25)
	instance.set("_max_energy", 15)
	instance.set("_energy", 0)
	instance.set("_energy_refilled_on", "2026-06-15")
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var buy_button: Button = _assert_button(instance, "BuyShopEnergyRefillButton", "shop should expose energy refill purchase")
	if buy_button != null:
		_assert_true(not buy_button.disabled, "energy refill purchase should be enabled for return guidance test")
		buy_button.emit_signal("pressed")
		await process_frame
		await process_frame

	_assert_exists(instance, "ShopPurchaseRewardOverlay", "energy refill purchase should show the shop purchase reward overlay")
	var guidance: Control = _assert_control(instance, "ShopEnergyRefillReturnGuidance", "energy refill reward should show a return-to-level guidance group")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_energy_refill_return_guidance", false)), "return guidance should be marked as Image2-sourced")
	var badge: TextureRect = _assert_texture_node(instance, "ShopEnergyRefillReturnBadge", RETURN_BADGE_PATH, "energy refill reward should show the Image2 return badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "return badge should not block the transparent action hit area")
	var label: Label = _assert_label(instance, "ShopEnergyRefillReturnLabel", "energy refill reward should label the return action")
	if label != null:
		_assert_true(label.text.contains("关") or label.text.contains("闯"), "return guidance label should point back to levels")
	var return_button: Button = _assert_button(instance, "ShopEnergyRefillReturnButton", "energy refill reward should expose a return-to-level action")
	if return_button != null:
		_assert_true(not return_button.disabled, "return-to-level action should be tappable")
		return_button.emit_signal("pressed")
		await _wait_until_missing(instance, "ShopPurchaseRewardOverlay")
		await _wait_until_exists(instance, "LevelSelectScreen")

	_assert_missing(instance, "ShopPurchaseRewardOverlay", "return action should close the purchase reward overlay")
	_assert_missing(instance, "ShopOverlay", "return action should leave the shop overlay")
	_assert_exists(instance, "LevelSelectScreen", "return action should open level select")
	var start_level: Button = _assert_button(instance, "StartLevel1Button", "refilled energy should leave level one playable")
	if start_level != null:
		_assert_true(not start_level.disabled, "level one should be enabled after returning from refill")
	_assert_true(_int_property(instance, "_energy") == 5, "return action should preserve the purchased energy")

	instance.queue_free()
	_finish()


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


func _int_property(instance: Node, property_name: String) -> int:
	var raw: Variant = instance.get(property_name)
	if raw == null:
		return 0
	return int(raw)


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _wait_frames(count: int) -> void:
	for index: int in range(count):
		await process_frame


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
		print("SHOP ENERGY REFILL RETURN TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SHOP ENERGY REFILL RETURN TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear shop energy refill return test save: %s" % error)
