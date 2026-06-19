extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_pause_quit_level_return_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const RETURN_REFERENCE_PATH := "res://assets/generated/ui/level_select_pause_quit_return_design_reference.png"
const RETURN_SOURCE_PATH := "res://assets/generated/ui/level_select_pause_quit_return_badge_source.png"
const RETURN_BADGE_PATH := "res://assets/generated/ui/level_select_pause_quit_return_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(RETURN_REFERENCE_PATH, "pause quit return guidance should keep an Image2 level-select design reference")
	_assert_file_exists(RETURN_SOURCE_PATH, "pause quit return guidance should keep its Image2-derived source asset")
	_assert_file_exists(RETURN_BADGE_PATH, "pause quit return guidance should use a transparent runtime badge")
	_assert_manifest_entry("level_select_pause_quit_return_design_reference", RETURN_REFERENCE_PATH)
	_assert_manifest_entry("level_select_pause_quit_return_badge_source", RETURN_SOURCE_PATH)
	_assert_manifest_entry("level_select_pause_quit_return_badge", RETURN_BADGE_PATH)

	var normal: Node = await _new_instance()
	if normal != null:
		normal.call("_show_level_select_now")
		await process_frame
		_assert_missing(normal, "PauseQuitLevelReturnGuidance", "normal level select should not show pause-quit return guidance")
		_cleanup_instance(normal)

	var instance: Node = await _new_instance()
	if instance == null:
		_finish()
		return
	instance.set("_max_energy", 15)
	instance.set("_energy", 6)
	instance.set("_energy_refilled_on", "2026-06-20")
	instance.call("_show_level_select_now")
	await process_frame

	var level_button: Button = _assert_button(instance, "StartLevel1Button", "level select should expose level one")
	if level_button != null:
		level_button.emit_signal("pressed")
		await process_frame
		await process_frame
	_assert_exists(instance, "BattleScene", "level one should start before testing pause quit")

	var pause_button: Button = _assert_button(instance, "PauseButton", "battle should expose pause")
	if pause_button != null:
		pause_button.emit_signal("pressed")
	await process_frame
	var quit_button: Button = _assert_button(instance, "QuitToLevelsButton", "pause menu should expose quit to level select")
	if quit_button != null:
		quit_button.emit_signal("pressed")
	for _frame: int in range(45):
		await process_frame

	_assert_exists(instance, "LevelSelectScreen", "pause quit should return to level select")
	var guidance: Control = _assert_control(instance, "PauseQuitLevelReturnGuidance", "returning from pause quit should show a level-select guidance group")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_pause_quit_return_guidance", false)), "pause quit return guidance should mark Image2 metadata")
	var badge: TextureRect = _assert_texture_node(instance, "PauseQuitLevelReturnBadge", RETURN_BADGE_PATH, "pause quit return guidance should show the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "pause quit return badge should not block level buttons")
	var label: Label = _assert_label(instance, "PauseQuitLevelReturnLabel", "pause quit return guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("重新选择") or label.text.contains("回到关卡"), "pause quit return copy should explain the player can choose again")
	var start_level: Button = _assert_button(instance, "StartLevel1Button", "guided level one should remain tappable")
	if start_level != null:
		_assert_true(not start_level.disabled, "guided level one should remain enabled")

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
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("PAUSE QUIT LEVEL RETURN GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("PAUSE QUIT LEVEL RETURN GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear pause quit level return guidance test save: %s" % error)
