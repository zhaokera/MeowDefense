extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/reward_overlay.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		push_error("Main scene failed to load")
		quit(1)
		return
	var instance: Node = scene.instantiate()
	root.add_child(instance)
	await process_frame
	var reward_button: Button = instance.find_child("DailyRewardButton", true, false) as Button
	if reward_button == null:
		push_error("DailyRewardButton missing")
		quit(1)
		return
	reward_button.emit_signal("pressed")
	await process_frame
	await process_frame
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(OUT_PATH)
	if error != OK:
		push_error("Failed to save %s: %s" % [OUT_PATH, error])
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	instance.queue_free()
	quit(0)
