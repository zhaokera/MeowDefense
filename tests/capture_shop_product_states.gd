extends SceneTree

const AFFORDABLE_OUT_PATH := "/Users/zhaok/cat/artifacts/shop_product_state_affordable.png"
const INSUFFICIENT_OUT_PATH := "/Users/zhaok/cat/artifacts/shop_product_state_insufficient.png"
const TEST_SAVE_PATH := "user://meow_defense_shop_product_state_capture_save.json"


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
	root.add_child(instance)
	await process_frame

	instance.set("_total_fish", 90)
	instance.set("_energy", 8)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	for i: int in range(8):
		await process_frame
	if not _save_viewport(AFFORDABLE_OUT_PATH):
		instance.queue_free()
		_clear_save_file()
		quit(1)
		return

	instance.set("_total_fish", 0)
	instance.set("_energy", 0)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	for i: int in range(8):
		await process_frame
	if not _save_viewport(INSUFFICIENT_OUT_PATH):
		instance.queue_free()
		_clear_save_file()
		quit(1)
		return

	print("CAPTURED %s" % AFFORDABLE_OUT_PATH)
	print("CAPTURED %s" % INSUFFICIENT_OUT_PATH)
	instance.queue_free()
	_clear_save_file()
	quit(0)


func _save_viewport(path: String) -> bool:
	var image: Image = root.get_texture().get_image()
	if image == null:
		push_error("failed to read viewport image")
		return false
	var error: Error = image.save_png(path)
	if error != OK:
		push_error("failed to save %s: %s" % [path, error])
		return false
	return true


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear shop product state capture save: %s" % error)
