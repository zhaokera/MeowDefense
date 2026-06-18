extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_hotspot_feedback_test_save.json"
const APP_SCRIPT_PATH := "res://scripts/app/main.gd"
const TAP_FEEDBACK_PATH := "res://assets/generated/ui/ui_tap_feedback_paw_spark.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	var source := _read_text(APP_SCRIPT_PATH)
	_assert_true(FileAccess.file_exists(TAP_FEEDBACK_PATH), "hotspot feedback should have a project-bound Image2 texture")
	_assert_true(source.contains("UI_TAP_FEEDBACK_TEXTURE"), "app hotspots should preload the Image2 tap feedback texture")

	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish()
		return
	var instance: Node = scene.instantiate()
	if instance == null:
		_failures.append("main scene should instantiate")
		_finish()
		return
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame

	var settings_button: Button = _find_by_name(instance, "SettingsButton") as Button
	if settings_button == null:
		_failures.append("main menu settings hotspot should exist")
	else:
		settings_button.emit_signal("button_down")
		await process_frame
		var feedback: TextureRect = _find_by_name(instance, "HotspotTapFeedback1") as TextureRect
		if feedback == null:
			_failures.append("hotspot press should spawn an Image2 tap feedback TextureRect")
		else:
			_assert_true(feedback.texture != null, "hotspot feedback should have a texture")
			if feedback.texture != null:
				_assert_true(feedback.texture.resource_path == TAP_FEEDBACK_PATH, "hotspot feedback should use the Image2 tap feedback texture")
			_assert_true(feedback.mouse_filter == Control.MOUSE_FILTER_IGNORE, "hotspot feedback should not block subsequent input")
		var pointer_event := InputEventMouseButton.new()
		pointer_event.button_index = MOUSE_BUTTON_LEFT
		pointer_event.pressed = true
		pointer_event.position = Vector2(42, 26)
		settings_button.emit_signal("gui_input", pointer_event)
		await process_frame
		var pointer_feedback: TextureRect = _find_by_name(instance, "HotspotTapFeedback2") as TextureRect
		if pointer_feedback == null:
			_failures.append("pointer press should spawn hotspot feedback at the touch position")
		else:
			var expected_center: Vector2 = settings_button.position + pointer_event.position
			var actual_center: Vector2 = pointer_feedback.position + pointer_feedback.size * 0.5
			_assert_true(actual_center.distance_to(expected_center) < 1.0, "hotspot feedback should be centered on the pointer position")

	instance.queue_free()
	_finish()


func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_failures.append("%s should be readable" % path)
		return ""
	return file.get_as_text()


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear hotspot feedback test save: %s" % error)


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


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("HOTSPOT FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("HOTSPOT FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
