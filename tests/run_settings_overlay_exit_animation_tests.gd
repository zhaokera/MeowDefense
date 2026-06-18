extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_settings_overlay_exit_animation_test_save.json"

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
	if instance == null:
		_failures.append("main scene should instantiate")
		_finish(null)
		return
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame

	var main_screen: Control = _find_by_name(instance, "MainMenuScreen") as Control
	if main_screen == null:
		_failures.append("main menu screen should exist")
		_finish(instance)
		return
	instance.call("_show_settings_overlay", main_screen)
	await process_frame

	var overlay: Control = _find_by_name(instance, "SettingsOverlay") as Control
	var close_button: Button = _find_by_name(instance, "CloseSettingsButton") as Button
	if overlay == null:
		_failures.append("settings overlay should exist before closing")
	elif close_button == null:
		_failures.append("settings close button should exist")
	else:
		close_button.emit_signal("pressed")
		_assert_true(is_instance_valid(overlay), "settings overlay should remain alive for exit animation immediately after close")
		_assert_true(overlay.get_meta("image2_overlay_exit_animation", false), "settings overlay should mark Image2 exit animation metadata")
		_assert_true(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "settings overlay should stop catching input while exiting")
		_assert_true(overlay.modulate.a < 1.0, "settings overlay should start fading out immediately during exit animation")
		_assert_true(close_button.disabled, "settings close button should disable during exit animation")
		for _frame: int in range(16):
			await process_frame
		_assert_true(_find_by_name(instance, "SettingsOverlay") == null, "settings overlay should be removed after exit animation")

	_finish(instance)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear settings overlay exit animation test save: %s" % error)


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish(instance: Node) -> void:
	_clear_save_file()
	if instance != null:
		instance.queue_free()
	if _failures.is_empty():
		print("SETTINGS OVERLAY EXIT ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SETTINGS OVERLAY EXIT ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
