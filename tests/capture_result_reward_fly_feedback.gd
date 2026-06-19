extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/result_reward_fly_feedback.png"
const TEST_SAVE_PATH := "user://meow_defense_result_reward_fly_feedback_capture_save.json"


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
	instance.set("_unlocked_level", 2)
	instance.call("_show_result", true, 3, 105)
	for i: int in range(20):
		await process_frame

	var fly_layer: Control = instance.find_child("ResultRewardFlyLayer", true, false) as Control
	if fly_layer == null:
		push_error("ResultRewardFlyLayer missing")
		quit(1)
		return
	var chip: TextureRect = instance.find_child("ResultRewardFlyFish1", true, false) as TextureRect
	if chip == null:
		push_error("ResultRewardFlyFish1 missing")
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
			push_error("failed to clear result reward fly capture save: %s" % error)
