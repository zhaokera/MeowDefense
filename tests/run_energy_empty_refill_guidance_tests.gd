extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_energy_empty_refill_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/energy_empty_refill_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/energy_empty_refill_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/energy_empty_refill_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "energy empty refill guidance should have a project-bound Image2 design reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "energy empty refill guidance should keep its Image2-derived source asset")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "energy empty refill guidance should have a transparent runtime badge")
	_assert_manifest_entry("energy_empty_refill_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("energy_empty_refill_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("energy_empty_refill_guidance_badge", GUIDANCE_BADGE_PATH)

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
	instance.call("_show_level_select_now")
	await process_frame
	var start_level: Button = _assert_button(instance, "StartLevel1Button", "level one should be available for the refill guidance flow")
	if start_level != null:
		start_level.emit_signal("pressed")
		await process_frame

	_assert_exists(instance, "EnergyEmptyOverlay", "zero energy should open the energy empty overlay")
	var guidance: Control = _assert_control(instance, "EnergyEmptyRefillGuidance", "energy empty overlay should show an Image2 refill guidance group")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_energy_refill_guidance", false)), "energy refill guidance should be marked as Image2-sourced")
	var badge: TextureRect = _assert_texture_node(instance, "EnergyEmptyRefillGuidanceBadge", GUIDANCE_BADGE_PATH, "energy empty overlay should show the Image2 refill guidance badge")
	var label: Label = _assert_label(instance, "EnergyEmptyRefillGuidanceLabel", "energy empty overlay should label the refill action")
	var refill_button: Button = _assert_button(instance, "EnergyEmptyRefillButton", "energy empty overlay should expose a refill action")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "guidance badge should not block the transparent action hit area")
	if label != null:
		_assert_true(label.text.contains("体力"), "refill guidance label should mention energy")
	if refill_button != null:
		_assert_true(not refill_button.disabled, "refill guidance action should be tappable")
		refill_button.emit_signal("pressed")
		await _wait_frames(45)

	_assert_missing(instance, "EnergyEmptyOverlay", "refill guidance should close the energy empty overlay before opening shop")
	_assert_exists(instance, "ShopOverlay", "refill guidance should route the player to the shop")
	var target: Control = _assert_control(instance, "ShopEnergyRefillButtonFrame", "shop should show the energy refill target after guidance")
	if target != null:
		_assert_true(bool(target.get_meta("image2_energy_refill_guidance_target", false)), "shop energy refill target should be marked and pulsed after guidance")
	_assert_true(_int_property(instance, "_energy") == 0, "guidance should not grant energy until the shop purchase is pressed")
	var shop_button: Button = _assert_button(instance, "BuyShopEnergyRefillButton", "shop should keep the actual energy purchase action")
	if shop_button != null:
		_assert_true(not shop_button.disabled, "energy purchase should be enabled when fish are sufficient")

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


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("ENERGY EMPTY REFILL GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ENERGY EMPTY REFILL GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear energy empty refill guidance test save: %s" % error)
