extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/shop_insufficient_fish_feedback.png"
const TEST_SAVE_PATH := "user://meow_defense_shop_insufficient_fish_capture_save.json"


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
	instance.set("_shop_starter_claimed", true)
	instance.set("_total_fish", 0)
	root.add_child(instance)
	await process_frame

	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var shortage_button: Button = instance.find_child("ShopPawBundleShortageButton", true, false) as Button
	if shortage_button == null:
		push_error("ShopPawBundleShortageButton missing")
		quit(1)
		return
	shortage_button.emit_signal("pressed")
	for i: int in range(16):
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
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear shop insufficient fish capture save: %s" % error)
