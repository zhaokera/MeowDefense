extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/settings_saved_feedback.png"
const TEST_SAVE_PATH := "user://meow_defense_settings_saved_feedback_capture_save.json"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		push_error("main scene missing")
		quit(1)
		return
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	instance.set("_music_enabled", true)
	instance.set("_effects_enabled", true)
	instance.set("_volume", 82.0)
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
	music_toggle.button_pressed = false
	await _wait_until_exists(instance, "SettingsSavedFeedback")
	for _frame: int in range(8):
		await process_frame

	await RenderingServer.frame_post_draw
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


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 120) -> void:
	for _frame: int in range(max_frames):
		if root_node.find_child(node_name, true, false) != null:
			return
		await process_frame


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear settings saved feedback capture save: %s" % error)
