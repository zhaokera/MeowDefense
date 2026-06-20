extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/backpack_organize_shop_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_backpack_organize_shop_guidance_capture_save.json"


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
	instance.set("_total_fish", 20)
	instance.set("_yarn_traps", 0)
	instance.set("_backpack_organized", false)
	root.add_child(instance)
	await process_frame

	instance.call("_show_backpack_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var organize_button: Button = instance.find_child("OrganizeBackpackButton", true, false) as Button
	if organize_button == null:
		push_error("OrganizeBackpackButton missing")
		quit(1)
		return
	organize_button.emit_signal("pressed")
	await _wait_until_exists(instance, "BackpackOrganizeShopGuidance")
	for _frame: int in range(60):
		await process_frame

	var guidance: Control = instance.find_child("BackpackOrganizeShopGuidance", true, false) as Control
	if guidance == null:
		push_error("BackpackOrganizeShopGuidance missing")
		quit(1)
		return
	var route_button: Button = instance.find_child("BackpackOrganizeShopButton", true, false) as Button
	if route_button == null:
		push_error("BackpackOrganizeShopButton missing")
		quit(1)
		return
	var label: Label = instance.find_child("BackpackOrganizeShopLabel", true, false) as Label
	if label == null or not label.text.contains("商店"):
		push_error("BackpackOrganizeShopLabel missing expected copy")
		quit(1)
		return

	await RenderingServer.frame_post_draw
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


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if root_node.find_child(node_name, true, false) != null:
			return
		await process_frame


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear backpack organize shop guidance capture save: %s" % error)
