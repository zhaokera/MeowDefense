extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_guidance_overlay_exit_animation_test_save.json"

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
	instance.set("_reward_date_override", "2026-06-19")
	root.add_child(instance)
	await process_frame

	await _open_locked_level_feedback(instance)
	await _assert_overlay_exit_animation(instance, "LockedLevelFeedbackOverlay", "CloseLockedLevelFeedbackButton", "locked level feedback")

	await _open_energy_empty_overlay(instance)
	await _assert_overlay_exit_animation(instance, "EnergyEmptyOverlay", "CloseEnergyEmptyButton", "energy empty")

	await _open_daily_task_overlay(instance)
	await _assert_overlay_exit_animation(instance, "DailyTaskOverlay", "CloseDailyTaskButton", "daily task")

	_finish(instance)


func _open_locked_level_feedback(instance: Node) -> void:
	instance.call("_show_level_select")
	await process_frame
	var locked_info: Button = _find_by_name(instance, "LockedLevel2InfoButton") as Button
	if locked_info == null:
		_failures.append("locked level feedback hit area should exist")
		return
	locked_info.emit_signal("pressed")
	await process_frame
	await process_frame


func _open_energy_empty_overlay(instance: Node) -> void:
	instance.set("_energy", 0)
	instance.set("_max_energy", 15)
	instance.call("_show_level_select")
	await process_frame
	var start_level: Button = _find_by_name(instance, "StartLevel1Button") as Button
	if start_level == null:
		_failures.append("level one start button should exist for energy check")
		return
	start_level.emit_signal("pressed")
	await process_frame
	await process_frame


func _open_daily_task_overlay(instance: Node) -> void:
	instance.call("_show_main_menu")
	await process_frame
	var task_button: Button = _find_by_name(instance, "DailyTaskButton") as Button
	if task_button == null:
		_failures.append("daily task entry should exist")
		return
	task_button.emit_signal("pressed")
	await process_frame
	await process_frame


func _assert_overlay_exit_animation(instance: Node, overlay_name: String, close_button_name: String, label: String) -> void:
	var overlay: Control = _find_by_name(instance, overlay_name) as Control
	var close_button: Button = _find_by_name(instance, close_button_name) as Button
	if overlay == null:
		_failures.append("%s overlay should exist before closing" % label)
		return
	if close_button == null:
		_failures.append("%s close button should exist" % label)
		return

	close_button.emit_signal("pressed")
	_assert_true(is_instance_valid(overlay), "%s overlay should remain alive for exit animation immediately after close" % label)
	if is_instance_valid(overlay):
		_assert_true(overlay.get_meta("image2_overlay_exit_animation", false), "%s overlay should mark Image2 exit animation metadata" % label)
		_assert_true(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "%s overlay should stop catching input while exiting" % label)
		_assert_true(overlay.modulate.a < 1.0, "%s overlay should start fading out immediately during exit animation" % label)
	_assert_true(close_button.disabled, "%s close button should disable during exit animation" % label)
	for _frame: int in range(45):
		await process_frame
	_assert_true(_find_by_name(instance, overlay_name) == null, "%s overlay should be removed after exit animation" % label)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear guidance overlay exit animation test save: %s" % error)


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
		print("GUIDANCE OVERLAY EXIT ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("GUIDANCE OVERLAY EXIT ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
