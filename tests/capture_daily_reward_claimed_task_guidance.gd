extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/daily_reward_claimed_task_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_daily_reward_claimed_task_guidance_capture_save.json"


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
	instance.set("_reward_date_override", "2026-06-20")
	instance.set("_daily_reward_claimed_on", "2026-06-20")
	instance.set("_daily_reward_claimed", true)
	root.add_child(instance)
	await process_frame
	instance.set("_daily_reward_claimed_on", "2026-06-20")
	instance.set("_daily_reward_claimed", true)

	var reward_button: Button = instance.find_child("DailyRewardButton", true, false) as Button
	if reward_button == null:
		push_error("DailyRewardButton missing")
		quit(1)
		return
	reward_button.emit_signal("pressed")
	await _wait_until_exists(instance, "RewardClaimedDailyTaskGuidance")
	for _frame: int in range(45):
		await process_frame

	var label: Label = instance.find_child("RewardClaimedDailyTaskLabel", true, false) as Label
	if label == null or not label.text.contains("任务"):
		push_error("RewardClaimedDailyTaskLabel missing expected copy")
		quit(1)
		return
	if instance.find_child("RewardClaimedDailyTaskButton", true, false) == null:
		push_error("RewardClaimedDailyTaskButton missing")
		quit(1)
		return

	await RenderingServer.frame_post_draw
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


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if root_node.find_child(node_name, true, false) != null:
			return
		await process_frame


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear claimed daily reward task guidance capture save: %s" % error)
