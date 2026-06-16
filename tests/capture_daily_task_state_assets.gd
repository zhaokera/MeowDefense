extends SceneTree

const READY_OUT_PATH := "/Users/zhaok/cat/artifacts/daily_task_state_ready.png"
const CLAIMED_OUT_PATH := "/Users/zhaok/cat/artifacts/daily_task_state_claimed.png"
const TEST_SAVE_PATH := "user://meow_defense_daily_task_state_capture_save.json"


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

	instance.set("_best_stars_by_level", {1: 3})
	instance.set("_yarn_traps", 0)
	instance.call("_recalculate_best_stars")
	await _open_daily_tasks(instance)
	for i: int in range(10):
		await process_frame
	if not _save_viewport(READY_OUT_PATH):
		_cleanup_and_quit(instance, 1)
		return

	var claim_button: Button = instance.find_child("ClaimDailyTaskFirstClearButton", true, false) as Button
	if claim_button == null:
		push_error("ClaimDailyTaskFirstClearButton missing")
		_cleanup_and_quit(instance, 1)
		return
	claim_button.emit_signal("pressed")
	await process_frame
	var reward_close: Button = instance.find_child("CloseDailyTaskClaimRewardButton", true, false) as Button
	if reward_close != null:
		reward_close.emit_signal("pressed")
	await process_frame
	await _open_daily_tasks(instance)
	for i: int in range(10):
		await process_frame
	if not _save_viewport(CLAIMED_OUT_PATH):
		_cleanup_and_quit(instance, 1)
		return

	print("CAPTURED %s" % READY_OUT_PATH)
	print("CAPTURED %s" % CLAIMED_OUT_PATH)
	_cleanup_and_quit(instance, 0)


func _open_daily_tasks(instance: Node) -> void:
	var existing: Node = instance.find_child("DailyTaskOverlay", true, false)
	if existing != null:
		existing.queue_free()
		await process_frame
	var task_button: Button = instance.find_child("DailyTaskButton", true, false) as Button
	if task_button == null:
		push_error("DailyTaskButton missing")
		return
	task_button.emit_signal("pressed")
	await process_frame


func _save_viewport(path: String) -> bool:
	var image: Image = root.get_texture().get_image()
	if image == null:
		push_error("failed to read viewport image")
		return false
	var error: Error = image.save_png(path)
	if error != OK:
		push_error("failed to save %s: %s" % [path, error])
		return false
	return true


func _cleanup_and_quit(instance: Node, code: int) -> void:
	instance.queue_free()
	_clear_save_file()
	quit(code)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear daily task state capture save: %s" % error)
