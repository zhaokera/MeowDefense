extends SceneTree

const OUT_DIR := "/Users/zhaok/cat/artifacts"
const TEST_SAVE_PATH := "user://meow_defense_reward_feedback_exit_animation_capture_save.json"


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
	instance.set("_reward_date_override", "2026-06-19")
	root.add_child(instance)
	await process_frame
	await process_frame

	if not await _capture_daily_reward_success_exit(instance):
		return
	if not await _capture_daily_task_reward_exit(instance):
		return

	instance.queue_free()
	_clear_save_file()
	quit(0)


func _capture_daily_reward_success_exit(instance: Node) -> bool:
	var reward_button: Button = instance.find_child("DailyRewardButton", true, false) as Button
	if reward_button == null:
		push_error("DailyRewardButton missing")
		quit(1)
		return false
	reward_button.emit_signal("pressed")
	await process_frame
	var claim_button: Button = instance.find_child("ClaimRewardButton", true, false) as Button
	if claim_button == null:
		push_error("ClaimRewardButton missing")
		quit(1)
		return false
	claim_button.emit_signal("pressed")
	await process_frame
	await process_frame
	return await _capture_overlay_exit(
		instance,
		"DailyRewardClaimSuccessOverlay",
		"CloseDailyRewardClaimSuccessButton",
		"daily_reward_claim_success_exit_animation.png"
	)


func _capture_daily_task_reward_exit(instance: Node) -> bool:
	instance.set("_best_stars_by_level", {1: 3})
	instance.set("_yarn_traps", 1)
	instance.call("_recalculate_best_stars")
	var task_button: Button = instance.find_child("DailyTaskButton", true, false) as Button
	if task_button == null:
		push_error("DailyTaskButton missing")
		quit(1)
		return false
	task_button.emit_signal("pressed")
	await process_frame
	var claim_button: Button = instance.find_child("ClaimDailyTaskFirstClearButton", true, false) as Button
	if claim_button == null:
		push_error("ClaimDailyTaskFirstClearButton missing")
		quit(1)
		return false
	claim_button.emit_signal("pressed")
	await process_frame
	await process_frame
	return await _capture_overlay_exit(
		instance,
		"DailyTaskClaimRewardOverlay",
		"CloseDailyTaskClaimRewardButton",
		"daily_task_claim_reward_exit_animation.png"
	)


func _capture_overlay_exit(instance: Node, overlay_name: String, close_button_name: String, file_name: String) -> bool:
	var overlay: Control = instance.find_child(overlay_name, true, false) as Control
	var close_button: Button = instance.find_child(close_button_name, true, false) as Button
	if overlay == null or close_button == null:
		push_error("%s or %s missing" % [overlay_name, close_button_name])
		quit(1)
		return false

	Engine.time_scale = 0.04
	close_button.emit_signal("pressed")
	await process_frame
	if not bool(overlay.get_meta("image2_overlay_exit_animation", false)):
		push_error("%s should mark Image2 exit animation" % overlay_name)
		Engine.time_scale = 1.0
		quit(1)
		return false
	if not is_instance_valid(overlay):
		push_error("%s should remain visible during slowed exit animation" % overlay_name)
		Engine.time_scale = 1.0
		quit(1)
		return false
	await RenderingServer.frame_post_draw

	var image: Image = root.get_texture().get_image()
	if image == null:
		push_error("failed to read viewport image")
		Engine.time_scale = 1.0
		quit(1)
		return false
	var output_path := "%s/%s" % [OUT_DIR, file_name]
	var error: Error = image.save_png(output_path)
	if error != OK:
		push_error("failed to save %s: %s" % [output_path, error])
		Engine.time_scale = 1.0
		quit(1)
		return false
	print("CAPTURED %s" % output_path)
	Engine.time_scale = 1.0
	if is_instance_valid(overlay):
		overlay.queue_free()
	await process_frame
	return true


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
