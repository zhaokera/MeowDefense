extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_screen_exit_animation_capture_save.json"
const MAIN_EXIT_PATH := "/Users/zhaok/cat/artifacts/main_menu_screen_exit_animation.png"
const LEVEL_EXIT_PATH := "/Users/zhaok/cat/artifacts/level_select_screen_exit_animation.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	if not await _capture_main_menu_exit():
		return
	if not await _capture_level_select_exit():
		return
	quit(0)


func _capture_main_menu_exit() -> bool:
	var instance: Node = await _new_main_instance()
	if instance == null:
		return false
	var main_screen: Control = instance.find_child("MainMenuScreen", true, false) as Control
	var start_button: Button = instance.find_child("StartLevelSelectButton", true, false) as Button
	if main_screen == null or start_button == null:
		return _fail("MainMenuScreen or StartLevelSelectButton missing", instance)

	Engine.time_scale = 0.04
	start_button.emit_signal("pressed")
	await process_frame
	if not bool(main_screen.get_meta("image2_screen_exit_animation", false)):
		return _fail("MainMenuScreen should mark Image2 screen exit animation", instance)
	if instance.find_child("LevelSelectScreen", true, false) != null:
		return _fail("LevelSelectScreen should wait for main menu exit animation", instance)
	var ok: bool = await _save_viewport(MAIN_EXIT_PATH, instance)
	_finish_instance(instance)
	return ok


func _capture_level_select_exit() -> bool:
	var instance: Node = await _new_main_instance()
	if instance == null:
		return false
	instance.call("_show_level_select_now")
	await process_frame
	for _frame: int in range(12):
		await process_frame
	var level_screen: Control = instance.find_child("LevelSelectScreen", true, false) as Control
	var back_button: Button = instance.find_child("BackToMainButton", true, false) as Button
	if level_screen == null or back_button == null:
		return _fail("LevelSelectScreen or BackToMainButton missing", instance)

	Engine.time_scale = 0.04
	back_button.emit_signal("pressed")
	await process_frame
	if not bool(level_screen.get_meta("image2_screen_exit_animation", false)):
		return _fail("LevelSelectScreen should mark Image2 screen exit animation", instance)
	if instance.find_child("MainMenuScreen", true, false) != null:
		return _fail("MainMenuScreen should wait for level select exit animation", instance)
	var ok: bool = await _save_viewport(LEVEL_EXIT_PATH, instance)
	_finish_instance(instance)
	return ok


func _new_main_instance() -> Node:
	Engine.time_scale = 1.0
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		push_error("main scene should load")
		quit(1)
		return null
	var instance: Node = scene.instantiate()
	if instance == null:
		push_error("main scene should instantiate")
		quit(1)
		return null
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame
	return instance


func _save_viewport(path: String, instance: Node) -> bool:
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	if image == null:
		return _fail("failed to read viewport image", instance)
	var error: Error = image.save_png(path)
	if error != OK:
		return _fail("failed to save %s: %s" % [path, error], instance)
	print("CAPTURED %s" % path)
	return true


func _fail(message: String, instance: Node) -> bool:
	push_error(message)
	_finish_instance(instance)
	quit(1)
	return false


func _finish_instance(instance: Node) -> void:
	Engine.time_scale = 1.0
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	_clear_save_file()


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
