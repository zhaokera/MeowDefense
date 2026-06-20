extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/achievement_continue_level_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_achievement_continue_level_guidance_capture_save.json"


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
	instance.set("_save_path", TEST_SAVE_PATH)
	instance.set("_reward_date_override", "2026-06-20")
	root.add_child(instance)
	await process_frame

	var achievements_button: Button = instance.find_child("BottomAchievementsButton", true, false) as Button
	if achievements_button == null:
		push_error("BottomAchievementsButton missing")
		quit(1)
		return
	achievements_button.emit_signal("pressed")
	await process_frame

	var action: Button = instance.find_child("AchievementsActionButton", true, false) as Button
	if action == null:
		push_error("AchievementsActionButton missing")
		quit(1)
		return
	action.emit_signal("pressed")
	await _wait_until_exists(instance, "AchievementContinueLevelGuidance")
	await RenderingServer.frame_post_draw

	var guidance: Control = instance.find_child("AchievementContinueLevelGuidance", true, false) as Control
	if guidance == null:
		push_error("AchievementContinueLevelGuidance missing")
		quit(1)
		return
	var label: Label = instance.find_child("AchievementContinueLevelLabel", true, false) as Label
	if label == null or not label.text.contains("继续挑战"):
		push_error("AchievementContinueLevelLabel missing expected copy")
		quit(1)
		return

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
	_clear_save_file()
	quit(0)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear achievement continue guidance capture save: %s" % error)


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if root_node.find_child(node_name, true, false) != null:
			return
		await process_frame
