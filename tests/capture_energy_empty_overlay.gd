extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/energy_empty_overlay.png"
const TEST_SAVE_PATH := "user://meow_defense_energy_empty_capture_save.json"


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
	instance.set("_reward_date_override", "2026-06-15")
	root.add_child(instance)
	await process_frame

	instance.set("_energy", 0)
	instance.set("_max_energy", 15)
	instance.call("_show_level_select_now")
	await process_frame
	var start_button: Button = instance.find_child("StartLevel1Button", true, false) as Button
	if start_button == null:
		push_error("StartLevel1Button missing")
		quit(1)
		return
	start_button.emit_signal("pressed")
	await create_timer(0.25).timeout

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
			push_error("failed to clear energy empty capture save: %s" % error)
