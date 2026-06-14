extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/result_screen.png"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	var instance: Node = scene.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	instance.call("_show_result", true, 3, 105)
	await process_frame
	await process_frame
	var viewport_texture: ViewportTexture = root.get_texture()
	if viewport_texture == null:
		push_error("failed to read viewport texture")
		quit(1)
		return
	var image: Image = viewport_texture.get_image()
	if image == null:
		push_error("failed to read viewport image")
		quit(1)
		return
	var result: Error = image.save_png(OUT_PATH)
	if result != OK:
		push_error("failed to save screenshot: %s" % result)
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	instance.queue_free()
	quit(0)
