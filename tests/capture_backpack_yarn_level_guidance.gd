extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/backpack_yarn_level_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_backpack_yarn_level_guidance_capture_save.json"


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
	instance.set("_yarn_traps", 2)

	var backpack_button: Button = instance.find_child("BottomBagButton", true, false) as Button
	if backpack_button == null:
		push_error("BottomBagButton missing")
		quit(1)
		return
	backpack_button.emit_signal("pressed")
	await process_frame

	var item_button: Button = instance.find_child("BackpackYarnTrapItemButton", true, false) as Button
	if item_button == null:
		push_error("BackpackYarnTrapItemButton missing")
		quit(1)
		return
	item_button.emit_signal("pressed")
	await process_frame

	var action: Button = instance.find_child("BackpackItemDetailActionButton", true, false) as Button
	if action == null:
		push_error("BackpackItemDetailActionButton missing")
		quit(1)
		return
	action.emit_signal("pressed")
	await _wait_until_exists(instance, "BackpackYarnLevelGuidance")
	for _frame: int in range(36):
		await process_frame
	await RenderingServer.frame_post_draw

	var guidance: Control = instance.find_child("BackpackYarnLevelGuidance", true, false) as Control
	if guidance == null:
		push_error("BackpackYarnLevelGuidance missing")
		quit(1)
		return
	var label: Label = instance.find_child("BackpackYarnLevelLabel", true, false) as Label
	if label == null or not label.text.contains("毛线"):
		push_error("BackpackYarnLevelLabel missing expected copy")
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
			push_error("failed to clear backpack yarn guidance capture save: %s" % error)
