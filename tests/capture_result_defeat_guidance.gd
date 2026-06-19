extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/result_defeat_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_defeat_guidance_capture_save.json"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame
	await process_frame
	instance.set("_current_level_id", 1)
	instance.call("_show_result", false, 0, 0)
	for _frame: int in range(24):
		await process_frame

	var guidance: Control = instance.find_child("ResultDefeatGuidance", true, false) as Control
	if guidance == null:
		push_error("ResultDefeatGuidance missing")
		quit(1)
		return
	var badge: TextureRect = instance.find_child("ResultDefeatGuidanceBadge", true, false) as TextureRect
	if badge == null:
		push_error("ResultDefeatGuidanceBadge missing")
		quit(1)
		return
	var label: Label = instance.find_child("ResultDefeatGuidanceLabel", true, false) as Label
	if label == null or not label.text.contains("再试"):
		push_error("ResultDefeatGuidanceLabel missing expected copy")
		quit(1)
		return
	var retry_button: Button = instance.find_child("RetryButton", true, false) as Button
	if retry_button == null or retry_button.disabled:
		push_error("RetryButton should remain enabled while defeat guidance is visible")
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
			push_error("failed to clear defeat guidance capture save: %s" % error)
