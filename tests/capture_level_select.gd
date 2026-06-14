extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/level_select.png"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	var instance: Node = scene.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame

	var start_button: Button = _find_by_name(instance, "StartLevelSelectButton") as Button
	if start_button == null:
		push_error("failed to find level select button")
		quit(1)
		return
	start_button.emit_signal("pressed")
	await process_frame
	await process_frame
	await process_frame

	var image: Image = root.get_texture().get_image()
	var result: Error = image.save_png(OUT_PATH)
	if result != OK:
		push_error("failed to save screenshot: %s" % result)
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	instance.queue_free()
	quit(0)


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null
