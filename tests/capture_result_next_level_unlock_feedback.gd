extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/result_next_level_unlock_feedback.png"
const TEST_SAVE_PATH := "user://meow_defense_result_next_level_unlock_feedback_capture_save.json"


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
	for i: int in range(45):
		await process_frame

	var feedback: TextureRect = instance.find_child("ResultNextLevelUnlockFeedback", true, false) as TextureRect
	if feedback == null:
		push_error("ResultNextLevelUnlockFeedback missing")
		quit(1)
		return
	var detail: Label = instance.find_child("ResultNextLevelUnlockDetail", true, false) as Label
	if detail == null or not detail.text.contains("第 2 关"):
		push_error("ResultNextLevelUnlockDetail missing level two copy")
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
			push_error("failed to clear result next-level unlock capture save: %s" % error)
