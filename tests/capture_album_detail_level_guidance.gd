extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/album_detail_level_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_album_detail_level_guidance_capture_save.json"


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

	var album_button: Button = instance.find_child("AlbumButton", true, false) as Button
	if album_button == null:
		push_error("AlbumButton missing")
		quit(1)
		return
	album_button.emit_signal("pressed")
	await process_frame

	var inspect_button: Button = instance.find_child("AlbumTowerInspectButton", true, false) as Button
	if inspect_button == null:
		push_error("AlbumTowerInspectButton missing")
		quit(1)
		return
	inspect_button.emit_signal("pressed")
	await process_frame

	var action: Button = instance.find_child("AlbumEntryDetailActionButton", true, false) as Button
	if action == null:
		push_error("AlbumEntryDetailActionButton missing")
		quit(1)
		return
	action.emit_signal("pressed")
	await _wait_until_exists(instance, "AlbumDetailLevelGuidance")
	for _frame: int in range(36):
		await process_frame
	await RenderingServer.frame_post_draw

	var guidance: Control = instance.find_child("AlbumDetailLevelGuidance", true, false) as Control
	if guidance == null:
		push_error("AlbumDetailLevelGuidance missing")
		quit(1)
		return
	var label: Label = instance.find_child("AlbumDetailLevelLabel", true, false) as Label
	if label == null or not label.text.contains("图鉴"):
		push_error("AlbumDetailLevelLabel missing expected copy")
		quit(1)
		return
	var start_level: Button = instance.find_child("StartLevel1Button", true, false) as Button
	if start_level == null or start_level.disabled:
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
			push_error("failed to clear album detail level guidance capture save: %s" % error)
