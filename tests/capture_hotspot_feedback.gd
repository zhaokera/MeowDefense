extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/hotspot_tap_feedback.png"


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
	await process_frame

	var start_button: Button = _find_by_name(instance, "StartLevelSelectButton") as Button
	if start_button == null:
		push_error("StartLevelSelectButton missing")
		quit(1)
		return
	var pointer_event := InputEventMouseButton.new()
	pointer_event.button_index = MOUSE_BUTTON_LEFT
	pointer_event.pressed = true
	pointer_event.position = Vector2(204, 30)
	start_button.emit_signal("gui_input", pointer_event)
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


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null
