extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_pause_settings_persistence_test_save.json"
const LEVEL_ONE := {
	"id": 1,
	"name": "鲜鱼草地",
	"path": "res://data/levels/level_001.json"
}

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish(null)
		return

	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame

	instance.set("_music_enabled", false)
	instance.set("_effects_enabled", false)
	instance.set("_volume", 35.0)
	instance.set("_energy", 3)
	instance.call("_start_level", LEVEL_ONE)
	await process_frame
	await process_frame

	var battle: Node = _assert_exists(instance, "BattleScene", "starting a level should enter battle")
	if battle == null:
		_finish(instance)
		return
	_open_pause_settings(battle)
	await process_frame

	var music_toggle: CheckButton = _assert_check_button(battle, "PauseMusicToggle", "pause settings should expose music toggle")
	var effects_toggle: CheckButton = _assert_check_button(battle, "PauseEffectsToggle", "pause settings should expose effects toggle")
	var volume_slider: HSlider = _assert_slider(battle, "PauseVolumeSlider", "pause settings should expose volume slider")
	if music_toggle != null:
		_assert_true(not music_toggle.button_pressed, "battle pause music toggle should inherit saved main music setting")
	if effects_toggle != null:
		_assert_true(not effects_toggle.button_pressed, "battle pause effects toggle should inherit saved main effects setting")
	if volume_slider != null:
		_assert_true(absf(float(volume_slider.value) - 35.0) < 0.01, "battle pause volume slider should inherit saved main volume")

	if music_toggle != null:
		music_toggle.button_pressed = true
		await process_frame
		_assert_true(bool(instance.get("_music_enabled")), "changing battle pause music should update main settings state")
	if effects_toggle != null:
		effects_toggle.button_pressed = true
		await process_frame
		_assert_true(bool(instance.get("_effects_enabled")), "changing battle pause effects should update main settings state")
	if volume_slider != null:
		volume_slider.value = 52.0
		await process_frame
		_assert_true(absf(float(instance.get("_volume")) - 52.0) < 0.01, "changing battle pause volume should update main settings state")

	_assert_saved_value("music_enabled", true, "battle pause music should persist to the player save")
	_assert_saved_value("effects_enabled", true, "battle pause effects should persist to the player save")
	_assert_saved_float("volume", 52.0, "battle pause volume should persist to the player save")

	instance.queue_free()
	await process_frame

	var reloaded: Node = scene.instantiate()
	reloaded.set("_save_path", TEST_SAVE_PATH)
	root.add_child(reloaded)
	await process_frame
	_assert_true(bool(reloaded.get("_music_enabled")), "reloaded app should restore battle-updated music setting")
	_assert_true(bool(reloaded.get("_effects_enabled")), "reloaded app should restore battle-updated effects setting")
	_assert_true(absf(float(reloaded.get("_volume")) - 52.0) < 0.01, "reloaded app should restore battle-updated volume setting")

	_finish(reloaded)


func _open_pause_settings(battle: Node) -> void:
	var pause_button: Button = _assert_button(battle, "PauseButton", "battle HUD should expose pause")
	if pause_button != null:
		pause_button.emit_signal("pressed")
	var settings_button: Button = _assert_button(battle, "PauseSettingsButton", "pause menu should expose settings")
	if settings_button != null:
		settings_button.emit_signal("pressed")


func _assert_saved_value(key: String, expected: bool, message: String) -> void:
	var data: Dictionary = _saved_data()
	if data.is_empty():
		return
	_assert_true(bool(data.get(key, not expected)) == expected, message)


func _assert_saved_float(key: String, expected: float, message: String) -> void:
	var data: Dictionary = _saved_data()
	if data.is_empty():
		return
	_assert_true(absf(float(data.get(key, -1.0)) - expected) < 0.01, message)


func _saved_data() -> Dictionary:
	if not FileAccess.file_exists(TEST_SAVE_PATH):
		_failures.append("settings persistence save file should exist")
		return {}
	var file := FileAccess.open(TEST_SAVE_PATH, FileAccess.READ)
	if file == null:
		_failures.append("settings persistence save file should be readable")
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed as Dictionary
	_failures.append("settings persistence save file should parse as a dictionary")
	return {}


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
	return null


func _assert_check_button(root_node: Node, node_name: String, message: String) -> CheckButton:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is CheckButton:
		return node as CheckButton
	_failures.append("%s should be a CheckButton" % node_name)
	return null


func _assert_slider(root_node: Node, node_name: String, message: String) -> HSlider:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is HSlider:
		return node as HSlider
	_failures.append("%s should be an HSlider" % node_name)
	return null


func _assert_exists(root_node: Node, node_name: String, message: String) -> Node:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
	return node


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


func _finish(instance: Node) -> void:
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	_clear_save_file()
	if _failures.is_empty():
		print("PAUSE SETTINGS PERSISTENCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("PAUSE SETTINGS PERSISTENCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear pause settings persistence test save: %s" % error)
