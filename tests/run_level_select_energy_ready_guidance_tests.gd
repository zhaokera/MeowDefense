extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_level_select_energy_ready_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const READY_REFERENCE_PATH := "res://assets/generated/ui/level_select_energy_ready_design_reference.png"
const READY_SOURCE_PATH := "res://assets/generated/ui/level_select_energy_ready_badge_source.png"
const READY_BADGE_PATH := "res://assets/generated/ui/level_select_energy_ready_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(READY_REFERENCE_PATH, "level energy-ready guidance should have a project-bound Image2 design reference")
	_assert_file_exists(READY_SOURCE_PATH, "level energy-ready guidance should keep its Image2-derived source asset")
	_assert_file_exists(READY_BADGE_PATH, "level energy-ready guidance should have a transparent runtime badge")
	_assert_manifest_entry("level_select_energy_ready_design_reference", READY_REFERENCE_PATH)
	_assert_manifest_entry("level_select_energy_ready_badge_source", READY_SOURCE_PATH)
	_assert_manifest_entry("level_select_energy_ready_badge", READY_BADGE_PATH)

	var normal: Node = await _new_instance("2026-06-15")
	if normal != null:
		normal.set("_max_energy", 15)
		normal.set("_energy", 5)
		normal.set("_energy_refilled_on", "2026-06-15")
		normal.call("_show_level_select_now")
		await process_frame
		_assert_missing(normal, "Level1EnergyReadyGuidance", "normal level select should not show post-refill guidance")
		_cleanup_instance(normal)

	var instance: Node = await _new_instance("2026-06-15")
	if instance == null:
		_finish()
		return
	instance.set("_total_fish", 25)
	instance.set("_max_energy", 15)
	instance.set("_energy", 0)
	instance.set("_energy_refilled_on", "2026-06-15")
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var buy_button: Button = _assert_button(instance, "BuyShopEnergyRefillButton", "shop should expose energy refill purchase")
	if buy_button != null:
		buy_button.emit_signal("pressed")
		await process_frame
		await process_frame
	var return_button: Button = _assert_button(instance, "ShopEnergyRefillReturnButton", "energy refill reward should expose return-to-level action")
	if return_button != null:
		return_button.emit_signal("pressed")
		await _wait_frames(45)

	_assert_exists(instance, "LevelSelectScreen", "returning from energy refill should open level select")
	var guidance: Control = _assert_control(instance, "Level1EnergyReadyGuidance", "post-refill level select should show an energy-ready guidance group")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_energy_ready_guidance", false)), "energy-ready guidance should be marked as Image2-sourced")
	var badge: TextureRect = _assert_texture_node(instance, "Level1EnergyReadyBadge", READY_BADGE_PATH, "energy-ready guidance should show the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "energy-ready badge should not block the level hit area")
	var label: Label = _assert_label(instance, "Level1EnergyReadyLabel", "energy-ready guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("开局") or label.text.contains("出发"), "energy-ready copy should point to starting the level")
	var start_level: Button = _assert_button(instance, "StartLevel1Button", "guided level one should remain tappable")
	if start_level != null:
		_assert_true(not start_level.disabled, "guided level one should be enabled")
		start_level.emit_signal("pressed")
		await process_frame

	_assert_exists(instance, "BattleScene", "pressing the guided level should enter battle")
	_assert_missing(instance, "Level1EnergyReadyGuidance", "starting battle should remove the level-select guidance with the screen")
	_assert_true(_int_property(instance, "_energy") == 4, "starting after refill guidance should consume one energy")

	_cleanup_instance(instance)
	_finish()


func _new_instance(date_key: String) -> Node:
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		return null
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	instance.set("_reward_date_override", date_key)
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
		print("LEVEL SELECT ENERGY READY GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("LEVEL SELECT ENERGY READY GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear level select energy-ready guidance test save: %s" % error)
