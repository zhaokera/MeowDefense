extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/level_select_current_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_level_select_current_guidance_capture_save.json"


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
	root.add_child(instance)
	await process_frame
	instance.call("_show_level_select_now")
	await process_frame

	var levels_button: Button = instance.find_child("BottomLevelsButton", true, false) as Button
	if levels_button == null:
		push_error("BottomLevelsButton missing")
		quit(1)
		return
	levels_button.emit_signal("pressed")
	await _wait_until_exists(instance, "LevelSelectCurrentGuidance")
	for _frame: int in range(36):
		await process_frame
	await RenderingServer.frame_post_draw

	var label: Label = instance.find_child("LevelSelectCurrentLabel", true, false) as Label
	if label == null or not label.text.contains("关卡"):
		push_error("LevelSelectCurrentLabel missing expected copy")
		quit(1)
		return
	var start_button: Button = instance.find_child("StartLevel1Button", true, false) as Button
	if start_button == null or start_button.disabled:
		push_error("StartLevel1Button missing or disabled")
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


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if root_node.find_child(node_name, true, false) != null:
			return
		await process_frame


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear level-select current guidance capture save: %s" % error)
