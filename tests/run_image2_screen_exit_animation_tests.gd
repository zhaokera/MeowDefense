extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_screen_exit_animation_test_save.json"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish(null)
		return
	var instance: Node = scene.instantiate()
	if instance == null:
		_failures.append("main scene should instantiate")
		_finish(null)
		return
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame

	var main_screen: Control = _find_by_name(instance, "MainMenuScreen") as Control
	var start_button: Button = _find_by_name(instance, "StartLevelSelectButton") as Button
	if main_screen == null:
		_failures.append("main menu screen should exist before level transition")
		_finish(instance)
		return
	if start_button == null:
		_failures.append("main menu start button should exist before level transition")
		_finish(instance)
		return

	start_button.emit_signal("pressed")
	_assert_screen_exit_started(main_screen, start_button, "main menu")
	_assert_true(_find_by_name(instance, "LevelSelectScreen") == null, "level select should wait for main menu exit animation")
	for _frame: int in range(45):
		await process_frame
	_assert_true(_find_by_name(instance, "MainMenuScreen") == null, "main menu should be removed after exit animation")
	var level_screen: Control = _find_by_name(instance, "LevelSelectScreen") as Control
	if level_screen == null:
		_failures.append("level select should appear after main menu exit animation")
		_finish(instance)
		return

	var back_button: Button = _find_by_name(instance, "BackToMainButton") as Button
	if back_button == null:
		_failures.append("level select back button should exist before main transition")
		_finish(instance)
		return
	back_button.emit_signal("pressed")
	_assert_screen_exit_started(level_screen, back_button, "level select")
	_assert_true(_find_by_name(instance, "MainMenuScreen") == null, "main menu should wait for level select exit animation")
	for _frame: int in range(45):
		await process_frame
	_assert_true(_find_by_name(instance, "LevelSelectScreen") == null, "level select should be removed after exit animation")
	_assert_true(_find_by_name(instance, "MainMenuScreen") != null, "main menu should appear after level select exit animation")

	_finish(instance)


func _assert_screen_exit_started(screen: Control, trigger_button: Button, label: String) -> void:
	_assert_true(is_instance_valid(screen), "%s should remain alive for Image2 screen exit animation" % label)
	if is_instance_valid(screen):
		_assert_true(screen.get_meta("image2_screen_exit_animation", false), "%s should mark Image2 screen exit animation metadata" % label)
		_assert_true(screen.mouse_filter == Control.MOUSE_FILTER_IGNORE, "%s should ignore input while exiting" % label)
		_assert_true(screen.modulate.a < 1.0, "%s should begin fading during screen exit animation" % label)
	_assert_true(trigger_button.disabled, "%s trigger button should disable during screen exit animation" % label)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear screen exit animation test save: %s" % error)


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish(instance: Node) -> void:
	_clear_save_file()
	if instance != null:
		instance.queue_free()
	if _failures.is_empty():
		print("IMAGE2 SCREEN EXIT ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("IMAGE2 SCREEN EXIT ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
