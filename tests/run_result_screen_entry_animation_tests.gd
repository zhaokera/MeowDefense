extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_result_entry_animation_test_save.json"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await _assert_result_entry_animation(true, "victory")
	await _assert_result_entry_animation(false, "defeat")
	_finish()


func _assert_result_entry_animation(won: bool, label: String) -> void:
	var instance: Node = await _main_instance()
	if instance == null:
		return
	instance.set("_current_level_id", 1)
	instance.call("_show_result", won, 3 if won else 0, 105 if won else 0)

	var screen: Control = _find_by_name(instance, "ResultScreen") as Control
	if screen == null:
		_failures.append("%s result screen should exist" % label)
		_cleanup_instance(instance)
		return

	_assert_true(bool(screen.get_meta("image2_result_entry_animation", false)), "%s result screen should mark Image2 entry animation metadata" % label)
	_assert_true(screen.position.y > 0.0, "%s result screen should start slightly below its settled position" % label)
	_assert_true(screen.scale.x > 1.0 and screen.scale.y > 1.0, "%s result screen should start with a tactile zoom state" % label)
	_assert_true(screen.modulate.a < 1.0, "%s result screen should start fading in instead of appearing instantly" % label)
	_assert_true(_find_by_name(instance, "ResultDesignBackground") != null, "%s result screen should keep the full Image2 design as the visual source" % label)

	for _frame: int in range(45):
		await process_frame
	_assert_true(screen.position == Vector2.ZERO, "%s result screen should settle at the viewport origin after entry animation" % label)
	_assert_true(screen.scale == Vector2.ONE, "%s result screen should settle at normal scale after entry animation" % label)
	_assert_true(is_equal_approx(screen.modulate.a, 1.0), "%s result screen should finish fully visible after entry animation" % label)
	_cleanup_instance(instance)


func _main_instance() -> Node:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		return null
	var instance: Node = scene.instantiate()
	if instance == null:
		_failures.append("main scene should instantiate")
		return null
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame
	return instance


func _cleanup_instance(instance: Node) -> void:
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	_clear_save_file()


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear result entry animation test save: %s" % error)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("RESULT SCREEN ENTRY ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("RESULT SCREEN ENTRY ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
