extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_result_entry_animation_capture_save.json"
const OUT_PATH := "/Users/zhaok/cat/artifacts/result_screen_entry_animation.png"


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
	await process_frame

	Engine.time_scale = 0.25
	instance.set("_current_level_id", 1)
	instance.call("_show_result", true, 3, 105)
	var screen: Control = instance.find_child("ResultScreen", true, false) as Control
	if screen == null:
		push_error("ResultScreen missing")
		_cleanup(instance)
		quit(1)
		return
	if not bool(screen.get_meta("image2_result_entry_animation", false)):
		push_error("ResultScreen should mark Image2 result entry animation")
		_cleanup(instance)
		quit(1)
		return
	for _frame: int in range(4):
		await process_frame
	await RenderingServer.frame_post_draw

	var image: Image = root.get_texture().get_image()
	if image == null:
		push_error("failed to read viewport image")
		_cleanup(instance)
		quit(1)
		return
	var error: Error = image.save_png(OUT_PATH)
	if error != OK:
		push_error("failed to save %s: %s" % [OUT_PATH, error])
		_cleanup(instance)
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	_cleanup(instance)
	quit(0)


func _cleanup(instance: Node) -> void:
	Engine.time_scale = 1.0
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	_clear_save_file()


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
