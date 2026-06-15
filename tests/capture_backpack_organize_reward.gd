extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/backpack_organize_reward.png"
const TEST_SAVE_PATH := "user://meow_defense_backpack_organize_capture_save.json"


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
	root.add_child(instance)
	await process_frame

	instance.set("_total_fish", 10)
	instance.set("_paw_tokens", 2)
	instance.set("_yarn_traps", 1)
	instance.call("_show_backpack_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var organize_button: Button = instance.find_child("OrganizeBackpackButton", true, false) as Button
	if organize_button == null:
		push_error("OrganizeBackpackButton missing")
		quit(1)
		return
	organize_button.emit_signal("pressed")
	for i: int in range(16):
		await process_frame

	var image: Image = root.get_texture().get_image()
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


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear backpack organize capture save: %s" % error)
