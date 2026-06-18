extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_screen_entry_animation_test_save.json"

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

	instance.call("_show_level_select_now")
	var level_screen: Control = _find_by_name(instance, "LevelSelectScreen") as Control
	if level_screen == null:
		_failures.append("level select screen should exist")
	else:
		_assert_entry_start(level_screen, "level select")
		await process_frame
		await process_frame
		_assert_true(level_screen.modulate.a > 0.0, "level select entry animation should start fading in after frames")

	instance.call("_show_main_menu_now")
	var main_screen: Control = _find_by_name(instance, "MainMenuScreen") as Control
	if main_screen == null:
		_failures.append("main menu screen should exist after returning")
	else:
		_assert_entry_start(main_screen, "main menu")

	_finish(instance)


func _assert_entry_start(screen: Control, label: String) -> void:
	_assert_true(screen.get_meta("image2_screen_entry_animation", false), "%s should mark Image2 screen entry animation metadata" % label)
	_assert_true(screen.pivot_offset.distance_to(Vector2(640, 360)) < 1.0, "%s entry animation should pivot from screen center" % label)
	_assert_true(screen.modulate.a < 1.0, "%s should begin below full opacity for fade-in" % label)
	_assert_true(screen.scale.x > 1.0 and screen.scale.y > 1.0, "%s should begin with a slight tactile zoom" % label)
	_assert_true(abs(screen.position.x) > 0.0 or abs(screen.position.y) > 0.0, "%s should begin with a small slide offset" % label)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear screen entry animation test save: %s" % error)


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
		print("IMAGE2 SCREEN ENTRY ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("IMAGE2 SCREEN ENTRY ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
