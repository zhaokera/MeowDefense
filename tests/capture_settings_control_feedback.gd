extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_settings_control_feedback_capture_save.json"
const OUT_PATH := "/Users/zhaok/cat/artifacts/settings_control_feedback.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		push_error("main scene should load")
		quit(1)
		return
	var instance: Node = scene.instantiate()
	if instance == null:
		push_error("main scene should instantiate")
		quit(1)
		return
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame

	var main_screen: Control = instance.find_child("MainMenuScreen", true, false) as Control
	if main_screen == null:
		push_error("MainMenuScreen missing")
		quit(1)
		return
	instance.call("_show_settings_overlay", main_screen)
	await process_frame

	var music_toggle: CheckButton = instance.find_child("MusicToggle", true, false) as CheckButton
	if music_toggle == null:
		push_error("MusicToggle missing")
		quit(1)
		return
	var pointer_event := InputEventMouseButton.new()
	pointer_event.button_index = MOUSE_BUTTON_LEFT
	pointer_event.pressed = true
	pointer_event.position = music_toggle.size * 0.5
	music_toggle.emit_signal("gui_input", pointer_event)
	await process_frame
	if instance.find_child("SettingsControlTapFeedback1", true, false) == null:
		push_error("SettingsControlTapFeedback1 missing after toggle pointer event")
		quit(1)
		return
	await process_frame
	await process_frame

	var image: Image = root.get_texture().get_image()
	if image == null:
		push_error("failed to read viewport image")
		quit(1)
		return
	var error: Error = image.save_png(OUT_PATH)
	if error != OK:
		push_error("failed to save %s: %s" % [OUT_PATH, error])
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	instance.queue_free()
	_clear_save_file()
	quit(0)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
