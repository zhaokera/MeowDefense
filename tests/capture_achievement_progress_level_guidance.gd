extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/achievement_progress_level_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_achievement_progress_level_guidance_capture_save.json"


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
	root.add_child(instance)
	await process_frame

	instance.call("_show_achievements_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var row_button: Button = instance.find_child("AchievementFirstClearButton", true, false) as Button
	if row_button == null:
		push_error("AchievementFirstClearButton missing")
		quit(1)
		return
	row_button.emit_signal("pressed")
	await _wait_until_exists(instance, "GoLevelsFromAchievementProgressButton")

	var levels_button: Button = instance.find_child("GoLevelsFromAchievementProgressButton", true, false) as Button
	if levels_button == null:
		push_error("GoLevelsFromAchievementProgressButton missing")
		quit(1)
		return
	levels_button.emit_signal("pressed")
	await _wait_until_exists(instance, "AchievementProgressLevelGuidance")
	for _frame: int in range(20):
		await process_frame

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


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 180) -> void:
	for _frame: int in range(max_frames):
		if root_node.find_child(node_name, true, false) != null:
			return
		await process_frame


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear achievement progress level guidance capture save: %s" % error)
