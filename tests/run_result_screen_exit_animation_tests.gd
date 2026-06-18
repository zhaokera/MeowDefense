extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_result_exit_animation_test_save.json"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await _assert_levels_button_uses_result_exit_animation()
	await _assert_retry_button_uses_result_exit_animation()
	await _assert_next_button_uses_result_exit_animation()
	_finish()


func _assert_levels_button_uses_result_exit_animation() -> void:
	var instance: Node = await _result_instance(1)
	if instance == null:
		return
	var screen: Control = _find_by_name(instance, "ResultScreen") as Control
	var button: Button = _find_by_name(instance, "ResultLevelsButton") as Button
	if screen == null or button == null:
		_failures.append("result screen and level-map button should exist")
		_cleanup_instance(instance)
		return

	button.emit_signal("pressed")
	_assert_result_exit_started(instance, screen, button, "level-map action")
	_assert_missing(instance, "LevelSelectScreen", "level-map action should not hard-cut to level select before exit animation")
	await _wait_frames(45)
	_assert_exists(instance, "LevelSelectScreen", "level-map action should open level select after result exit animation")
	_cleanup_instance(instance)


func _assert_retry_button_uses_result_exit_animation() -> void:
	var instance: Node = await _result_instance(1)
	if instance == null:
		return
	var screen: Control = _find_by_name(instance, "ResultScreen") as Control
	var button: Button = _find_by_name(instance, "RetryButton") as Button
	if screen == null or button == null:
		_failures.append("result screen and retry button should exist")
		_cleanup_instance(instance)
		return

	button.emit_signal("pressed")
	_assert_result_exit_started(instance, screen, button, "retry action")
	_assert_missing(instance, "BattleScene", "retry action should not hard-cut to battle before exit animation")
	await _wait_frames(45)
	_assert_exists(instance, "BattleScene", "retry action should start battle after result exit animation")
	_assert_true(int(instance.get("_current_level_id")) == 1, "retry action should restart the current level")
	_cleanup_instance(instance)


func _assert_next_button_uses_result_exit_animation() -> void:
	var instance: Node = await _result_instance(1)
	if instance == null:
		return
	var screen: Control = _find_by_name(instance, "ResultScreen") as Control
	var button: Button = _find_by_name(instance, "NextLevelButton") as Button
	if screen == null or button == null:
		_failures.append("result screen and next-level button should exist")
		_cleanup_instance(instance)
		return
	_assert_true(not button.disabled, "winning level one should enable next-level button")

	button.emit_signal("pressed")
	_assert_result_exit_started(instance, screen, button, "next-level action")
	_assert_missing(instance, "BattleScene", "next-level action should not hard-cut to battle before exit animation")
	await _wait_frames(45)
	_assert_exists(instance, "BattleScene", "next-level action should start battle after result exit animation")
	_assert_true(int(instance.get("_current_level_id")) == 2, "next-level action should start the unlocked next level")
	_cleanup_instance(instance)


func _result_instance(level_id: int) -> Node:
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
	instance.set("_current_level_id", level_id)
	instance.set("_energy", 15)
	instance.call("_show_result", true, 3, 105)
	await process_frame
	return instance


func _assert_result_exit_started(root_node: Node, screen: Control, trigger_button: Button, label: String) -> void:
	_assert_true(is_instance_valid(screen), "%s should keep result screen alive during exit animation" % label)
	if not is_instance_valid(screen):
		return
	_assert_true(bool(screen.get_meta("image2_result_exit_animation", false)), "%s should mark Image2 result exit animation metadata" % label)
	_assert_true(screen.mouse_filter == Control.MOUSE_FILTER_IGNORE, "%s should ignore input while result screen exits" % label)
	_assert_true(screen.modulate.a < 1.0, "%s should start fading the result screen immediately" % label)
	_assert_true(trigger_button.disabled, "%s should disable the pressed result button during exit animation" % label)
	for button_name: String in ["RetryButton", "ResultLevelsButton", "NextLevelButton"]:
		var button: Button = _find_by_name(root_node, button_name) as Button
		if button != null:
			_assert_true(button.disabled, "%s should disable %s during result exit animation" % [label, button_name])


func _wait_frames(count: int) -> void:
	for _frame: int in range(count):
		await process_frame


func _cleanup_instance(instance: Node) -> void:
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	_clear_save_file()


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear result exit animation test save: %s" % error)


func _assert_exists(root_node: Node, node_name: String, message: String) -> Node:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
	return node


func _assert_missing(root_node: Node, node_name: String, message: String) -> void:
	if _find_by_name(root_node, node_name) != null:
		_failures.append(message)


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
		print("RESULT SCREEN EXIT ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("RESULT SCREEN EXIT ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
