extends SceneTree

const OUT_DIR := "/Users/zhaok/cat/artifacts"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		push_error("main scene missing")
		quit(1)
		return
	var instance: Node = scene.instantiate()
	root.add_child(instance)
	await process_frame

	if not await _press_and_capture(instance, "BottomBagButton", "backpack_overlay.png"):
		return
	if not await _press_and_capture(instance, "BottomAchievementsButton", "achievements_overlay.png"):
		return
	if not await _press_and_capture(instance, "BottomShopButton", "shop_overlay.png"):
		return

	instance.queue_free()
	quit(0)


func _press_and_capture(instance: Node, button_name: String, file_name: String) -> bool:
	var button: Button = instance.find_child(button_name, true, false) as Button
	if button == null:
		push_error("%s missing" % button_name)
		quit(1)
		return false
	button.emit_signal("pressed")
	await process_frame
	await process_frame
	var image: Image = root.get_texture().get_image()
	var output_path := "%s/%s" % [OUT_DIR, file_name]
	var error: Error = image.save_png(output_path)
	if error != OK:
		push_error("Failed to save %s: %s" % [output_path, error])
		quit(1)
		return false
	print("CAPTURED %s" % output_path)
	var overlay: Node = instance.find_child(file_name.get_basename().to_pascal_case().replace("Overlay", "") + "Overlay", true, false)
	if overlay != null:
		overlay.queue_free()
		await process_frame
	return true
