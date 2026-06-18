extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_settings_control_feedback_test_save.json"
const TAP_FEEDBACK_PATH := "res://assets/generated/ui/ui_tap_feedback_paw_spark.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_true(FileAccess.file_exists(TAP_FEEDBACK_PATH), "settings control feedback should use the project-bound Image2 tap texture")

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

	var music_toggle: CheckButton = _find_by_name(instance, "MusicToggle") as CheckButton
	if music_toggle == null:
		_failures.append("settings music toggle should exist")
	else:
		var toggle_event := InputEventMouseButton.new()
		toggle_event.button_index = MOUSE_BUTTON_LEFT
		toggle_event.pressed = true
		toggle_event.position = Vector2(38, 30)
		music_toggle.emit_signal("gui_input", toggle_event)
		await process_frame

		var toggle_feedback: TextureRect = _find_by_name(instance, "SettingsControlTapFeedback1") as TextureRect
		if toggle_feedback == null:
			_failures.append("settings toggle press should spawn Image2 tap feedback")
		else:
			_assert_feedback(toggle_feedback, music_toggle.position + toggle_event.position, "settings toggle")

	var volume_slider: HSlider = _find_by_name(instance, "VolumeSlider") as HSlider
	if volume_slider == null:
		_failures.append("settings volume slider should exist")
	else:
		var slider_event := InputEventMouseButton.new()
		slider_event.button_index = MOUSE_BUTTON_LEFT
		slider_event.pressed = true
		slider_event.position = Vector2(210, 34)
		volume_slider.emit_signal("gui_input", slider_event)
		await process_frame

		var slider_feedback: TextureRect = _find_by_name(instance, "SettingsControlTapFeedback2") as TextureRect
		if slider_feedback == null:
			_failures.append("settings slider press should spawn Image2 tap feedback")
		else:
			_assert_feedback(slider_feedback, volume_slider.position + slider_event.position, "settings slider")

	_finish(instance)


func _assert_feedback(feedback: TextureRect, expected_center: Vector2, label: String) -> void:
	_assert_true(feedback.texture != null, "%s feedback should have a texture" % label)
	if feedback.texture != null:
		_assert_true(feedback.texture.resource_path == TAP_FEEDBACK_PATH, "%s feedback should use the Image2 tap texture" % label)
	_assert_true(feedback.mouse_filter == Control.MOUSE_FILTER_IGNORE, "%s feedback should not block input" % label)
	var actual_center: Vector2 = feedback.position + feedback.size * 0.5
	_assert_true(actual_center.distance_to(expected_center) < 1.0, "%s feedback should be centered on the pointer position" % label)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear settings control feedback test save: %s" % error)


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
		print("SETTINGS CONTROL FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SETTINGS CONTROL FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
