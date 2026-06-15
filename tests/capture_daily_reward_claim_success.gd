extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/daily_reward_claim_success.png"
const TEST_SAVE_PATH := "user://meow_defense_daily_reward_claim_success_capture_save.json"


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
	instance.set("_reward_date_override", "2026-06-16")
	root.add_child(instance)
	await process_frame

	var reward_button: Button = instance.find_child("DailyRewardButton", true, false) as Button
	if reward_button == null:
		push_error("DailyRewardButton missing")
		quit(1)
		return
	reward_button.emit_signal("pressed")
	await process_frame
	var claim_button: Button = instance.find_child("ClaimRewardButton", true, false) as Button
	if claim_button == null:
		push_error("ClaimRewardButton missing")
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
			push_error("failed to clear daily reward claim success capture save: %s" % error)
