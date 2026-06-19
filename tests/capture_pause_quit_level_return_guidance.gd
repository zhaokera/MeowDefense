extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/pause_quit_level_return_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_pause_quit_level_return_guidance_capture_save.json"


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
	instance.set("_max_energy", 15)
	instance.set("_energy", 6)
	instance.set("_energy_refilled_on", "2026-06-20")
	instance.call("_show_level_select_now")
	await process_frame

	var level_button: Button = instance.find_child("StartLevel1Button", true, false) as Button
	if level_button == null:
		push_error("StartLevel1Button missing")
		quit(1)
		return
	level_button.emit_signal("pressed")
	await process_frame
	await process_frame

	var pause_button: Button = instance.find_child("PauseButton", true, false) as Button
	if pause_button == null:
		push_error("PauseButton missing")
		quit(1)
		return
	pause_button.emit_signal("pressed")
	await process_frame

	var quit_button: Button = instance.find_child("QuitToLevelsButton", true, false) as Button
	if quit_button == null:
		push_error("QuitToLevelsButton missing")
		quit(1)
		return
	quit_button.emit_signal("pressed")
	for _frame: int in range(45):
		await process_frame
	await RenderingServer.frame_post_draw

	var guidance: Control = instance.find_child("PauseQuitLevelReturnGuidance", true, false) as Control
	if guidance == null:
		push_error("PauseQuitLevelReturnGuidance missing")
		quit(1)
		return
	var badge: TextureRect = instance.find_child("PauseQuitLevelReturnBadge", true, false) as TextureRect
	if badge == null:
		push_error("PauseQuitLevelReturnBadge missing")
		quit(1)
		return
	var label: Label = instance.find_child("PauseQuitLevelReturnLabel", true, false) as Label
	if label == null or not label.text.contains("重新选择"):
		push_error("PauseQuitLevelReturnLabel missing expected copy")
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
			push_error("failed to clear pause quit guidance capture save: %s" % error)
