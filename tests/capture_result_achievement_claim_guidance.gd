extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/result_achievement_claim_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_result_achievement_claim_guidance_capture_save.json"


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
	await process_frame

	instance.set("_current_level_id", 1)
	instance.set("_unlocked_level", 1)
	instance.call("_show_result", true, 3, 35)
	await _wait_until_exists(instance, "ResultAchievementClaimGuidance")
	for _frame: int in range(45):
		await process_frame
	await RenderingServer.frame_post_draw

	var route_button: Button = instance.find_child("ResultAchievementClaimGuidanceButton", true, false) as Button
	if route_button == null:
		push_error("ResultAchievementClaimGuidanceButton missing")
		quit(1)
		return
	var label: Label = instance.find_child("ResultAchievementClaimGuidanceLabel", true, false) as Label
	if label == null or not label.text.contains("成就"):
		push_error("ResultAchievementClaimGuidanceLabel missing expected copy")
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
			push_error("failed to clear result achievement guidance capture save: %s" % error)
