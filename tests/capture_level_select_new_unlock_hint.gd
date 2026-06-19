extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/level_select_new_unlock_hint.png"
const TEST_SAVE_PATH := "user://meow_defense_level_select_new_unlock_hint_capture_save.json"


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

	instance.set("_unlocked_level", 2)
	instance.set("_best_stars_by_level", {1: 3})
	instance.call("_show_level_select_now")
	for i: int in range(35):
		await process_frame

	var hint: TextureRect = instance.find_child("Level2NewUnlockHint", true, false) as TextureRect
	if hint == null:
		push_error("Level2NewUnlockHint missing")
		quit(1)
		return
	var label: Label = instance.find_child("Level2NewUnlockLabel", true, false) as Label
	if label == null or not label.text.contains("新关卡"):
		push_error("Level2NewUnlockLabel missing new-level copy")
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
			push_error("failed to clear level select new-unlock hint capture save: %s" % error)
