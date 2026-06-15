extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/daily_task_claim_reward.png"
const TEST_SAVE_PATH := "user://meow_defense_daily_task_claim_reward_capture_save.json"


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
	instance.set("_yarn_traps", 1)
	instance.call("_recalculate_best_stars")
	var task_button: Button = instance.find_child("DailyTaskButton", true, false) as Button
	if task_button == null:
		push_error("DailyTaskButton missing")
		quit(1)
		return
	task_button.emit_signal("pressed")
	await process_frame
	var claim_button: Button = instance.find_child("ClaimDailyTaskFirstClearButton", true, false) as Button
	if claim_button == null:
		push_error("ClaimDailyTaskFirstClearButton missing")
		quit(1)
		return
	claim_button.emit_signal("pressed")
	for i: int in range(16):
		await process_frame

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
	var error: Error = image.save_png(OUT_PATH)
	if error != OK:
		push_error("failed to save %s: %s" % [OUT_PATH, error])
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
			push_error("failed to clear daily task claim reward capture save: %s" % error)
