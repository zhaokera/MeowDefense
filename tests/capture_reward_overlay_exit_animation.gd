extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/reward_overlay_exit_animation.png"
const TEST_SAVE_PATH := "user://meow_defense_reward_overlay_exit_animation_capture_save.json"


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

	var reward_button: Button = instance.find_child("DailyRewardButton", true, false) as Button
	if reward_button == null:
		push_error("DailyRewardButton missing")
		quit(1)
		return
	reward_button.emit_signal("pressed")
	await process_frame
	for _frame: int in range(12):
		await process_frame

	var overlay: Control = instance.find_child("RewardOverlay", true, false) as Control
	var close_button: Button = instance.find_child("CloseRewardButton", true, false) as Button
	if overlay == null or close_button == null:
		push_error("RewardOverlay or CloseRewardButton missing")
		quit(1)
		return

	Engine.time_scale = 0.04
	close_button.emit_signal("pressed")
	await process_frame
	if not bool(overlay.get_meta("image2_overlay_exit_animation", false)):
		push_error("RewardOverlay should mark Image2 exit animation")
		Engine.time_scale = 1.0
		quit(1)
		return
	if not is_instance_valid(overlay):
		push_error("RewardOverlay should remain visible during slowed exit animation")
		Engine.time_scale = 1.0
		quit(1)
		return
	await RenderingServer.frame_post_draw

	var image: Image = root.get_texture().get_image()
	if image == null:
		push_error("failed to read viewport image")
		Engine.time_scale = 1.0
		quit(1)
		return
	var error: Error = image.save_png(OUT_PATH)
	if error != OK:
		push_error("failed to save %s: %s" % [OUT_PATH, error])
		Engine.time_scale = 1.0
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	Engine.time_scale = 1.0
	if is_instance_valid(overlay):
		overlay.queue_free()
	instance.queue_free()
	_clear_save_file()
	quit(0)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
