extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/level_select_locked.png"
const TEST_SAVE_PATH := "user://meow_defense_locked_capture_save.json"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()

	var scene: PackedScene = load("res://scenes/main.tscn")
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame
	await process_frame

	instance.call("_show_level_select_now")
	await process_frame
	await process_frame
	await process_frame

	var image: Image = root.get_texture().get_image()
	if image == null:
		push_error("failed to capture viewport image")
		quit(1)
		return
	var result: Error = image.save_png(OUT_PATH)
	if result != OK:
		push_error("failed to save screenshot: %s" % result)
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	instance.queue_free()
	_clear_save_file()
	quit(0)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear capture save: %s" % error)
