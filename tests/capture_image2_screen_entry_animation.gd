extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_screen_entry_animation_capture_save.json"
const OUT_PATH := "/Users/zhaok/cat/artifacts/image2_screen_entry_animation.png"


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

	instance.call("_show_level_select")
	await process_frame
	var level_screen: Control = instance.find_child("LevelSelectScreen", true, false) as Control
	if level_screen == null:
		push_error("LevelSelectScreen missing")
		quit(1)
		return
	if not bool(level_screen.get_meta("image2_screen_entry_animation", false)):
		push_error("LevelSelectScreen should mark Image2 screen entry animation")
		quit(1)
		return
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
