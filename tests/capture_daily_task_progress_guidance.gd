extends SceneTree

const OVERLAY_OUT_PATH := "/Users/zhaok/cat/artifacts/daily_task_progress_guidance.png"
const LEVEL_OUT_PATH := "/Users/zhaok/cat/artifacts/daily_task_progress_level_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_daily_task_progress_guidance_capture_save.json"


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

	var task_button: Button = instance.find_child("DailyTaskButton", true, false) as Button
	if task_button == null:
		push_error("DailyTaskButton missing")
		quit(1)
		return
	task_button.emit_signal("pressed")
	await _wait_until_exists(instance, "DailyTaskFirstClearProgressButton")

	var progress_button: Button = instance.find_child("DailyTaskFirstClearProgressButton", true, false) as Button
	if progress_button == null:
		push_error("DailyTaskFirstClearProgressButton missing")
		quit(1)
		return
	progress_button.emit_signal("pressed")
	await _wait_until_exists(instance, "DailyTaskProgressGuidanceOverlay")
	for _frame: int in range(20):
		await process_frame
	await _save_viewport(OVERLAY_OUT_PATH)

	var levels_button: Button = instance.find_child("GoLevelsFromDailyTaskProgressButton", true, false) as Button
	if levels_button == null:
		push_error("GoLevelsFromDailyTaskProgressButton missing")
		quit(1)
		return
	levels_button.emit_signal("pressed")
	await _wait_until_exists(instance, "DailyTaskProgressLevelGuidance")
	for _frame: int in range(20):
		await process_frame
	await _save_viewport(LEVEL_OUT_PATH)

	print("CAPTURED %s" % OVERLAY_OUT_PATH)
	print("CAPTURED %s" % LEVEL_OUT_PATH)
	instance.queue_free()
	_clear_save_file()
	quit(0)


func _save_viewport(out_path: String) -> void:
	for _frame: int in range(3):
		await process_frame
	var image: Image = root.get_texture().get_image()
	if image == null:
		push_error("failed to read viewport image")
		quit(1)
		return
	var error: Error = image.save_png(out_path)
	if error != OK:
		push_error("failed to save %s: %s" % [out_path, error])
		quit(1)


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 180) -> void:
	for _frame: int in range(max_frames):
		if root_node.find_child(node_name, true, false) != null:
			return
		await process_frame


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear daily task progress guidance capture save: %s" % error)
