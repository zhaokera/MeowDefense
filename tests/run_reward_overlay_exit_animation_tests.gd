extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_reward_overlay_exit_animation_test_save.json"

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

	var reward_button: Button = _find_by_name(instance, "DailyRewardButton") as Button
	if reward_button == null:
		_failures.append("daily reward button should exist")
		_finish(instance)
		return
	reward_button.emit_signal("pressed")
	await process_frame

	var overlay: Control = _find_by_name(instance, "RewardOverlay") as Control
	var close_button: Button = _find_by_name(instance, "CloseRewardButton") as Button
	if overlay == null:
		_failures.append("reward overlay should exist before closing")
		_finish(instance)
		return
	if close_button == null:
		_failures.append("reward close button should exist")
		_finish(instance)
		return

	close_button.emit_signal("pressed")
	_assert_true(is_instance_valid(overlay), "reward overlay should remain alive for exit animation immediately after close")
	if is_instance_valid(overlay):
		_assert_true(overlay.get_meta("image2_overlay_exit_animation", false), "reward overlay should mark Image2 exit animation metadata")
		_assert_true(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "reward overlay should stop catching input while exiting")
		_assert_true(overlay.modulate.a < 1.0, "reward overlay should start fading out immediately during exit animation")
	_assert_true(close_button.disabled, "reward close button should disable during exit animation")
	for _frame: int in range(45):
		await process_frame
	_assert_true(_find_by_name(instance, "RewardOverlay") == null, "reward overlay should be removed after exit animation")

	_finish(instance)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear reward overlay exit animation test save: %s" % error)


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
		print("REWARD OVERLAY EXIT ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("REWARD OVERLAY EXIT ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
