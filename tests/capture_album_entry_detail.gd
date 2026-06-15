extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/album_entry_detail.png"


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

	var album_button: Button = instance.find_child("AlbumButton", true, false) as Button
	if album_button == null:
		push_error("AlbumButton missing")
		quit(1)
		return
	album_button.emit_signal("pressed")
	await process_frame
	var inspect_button: Button = instance.find_child("AlbumTowerInspectButton", true, false) as Button
	if inspect_button == null:
		push_error("AlbumTowerInspectButton missing")
		quit(1)
		return
	inspect_button.emit_signal("pressed")
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
	quit(0)
