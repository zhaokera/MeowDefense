extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_daily_task_test_save.json"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish()
		return
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame

	instance.set("_best_stars_by_level", {1: 3})
	instance.call("_recalculate_best_stars")
	var before_fish: int = int(instance.get("_total_fish"))
	var task_button: Button = _assert_button(instance, "DailyTaskButton", "main menu should expose daily task entry")
	if task_button != null:
		task_button.emit_signal("pressed")
		await process_frame

	_assert_exists(instance, "DailyTaskOverlay", "daily task entry should open a dedicated overlay")
	_assert_texture_node(
		instance,
		"DailyTaskDesignBackground",
		"res://assets/generated/ui/daily_task_overlay_design_reference.png",
		"daily task overlay should render from its Image2 full-screen design"
	)
	_assert_missing(instance, "RewardOverlay", "daily task should not reuse daily reward overlay")
	_assert_missing(instance, "DailyTaskPanel", "daily task should not use a code-drawn panel")
	var first_progress: Label = _assert_label(instance, "DailyTaskFirstClearProgress", "daily task should show first clear progress")
	if first_progress != null:
		_assert_true(first_progress.text.contains("1/1"), "first clear daily task should be ready from saved progress")
	var claim_button: Button = _assert_button(instance, "ClaimDailyTaskFirstClearButton", "daily task should expose a claim button")
	if claim_button != null:
		_assert_true(not claim_button.disabled, "ready daily task should be claimable")
		claim_button.emit_signal("pressed")
		await process_frame

	_assert_true(int(instance.get("_total_fish")) == before_fish + 30, "claiming daily task should grant fish")
	var claimed_label: Label = _assert_label(instance, "DailyTaskFirstClearClaimLabel", "claimed task should update its claim label")
	if claimed_label != null:
		_assert_true(claimed_label.text == "已领取", "claimed daily task should show claimed state")
	if claim_button != null:
		_assert_true(claim_button.disabled, "claimed daily task should disable its claim button")

	instance.queue_free()
	await process_frame
	var reloaded: Node = scene.instantiate()
	reloaded.set("_save_path", TEST_SAVE_PATH)
	root.add_child(reloaded)
	await process_frame
	_assert_true(int(reloaded.get("_total_fish")) == before_fish + 30, "daily task reward should persist after reload")
	var reloaded_task: Button = _assert_button(reloaded, "DailyTaskButton", "reloaded main menu should expose daily task entry")
	if reloaded_task != null:
		reloaded_task.emit_signal("pressed")
		await process_frame
	var reloaded_label: Label = _assert_label(reloaded, "DailyTaskFirstClearClaimLabel", "daily task claimed state should reload")
	if reloaded_label != null:
		_assert_true(reloaded_label.text == "已领取", "daily task claim state should persist")
	reloaded.queue_free()
	_finish()


func _assert_texture_node(root_node: Node, node_name: String, expected_path: String, message: String) -> TextureRect:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if not node is TextureRect:
		_failures.append("%s should be a TextureRect" % node_name)
		return null
	var texture_rect: TextureRect = node as TextureRect
	_assert_true(texture_rect.texture != null, "%s should have a texture" % node_name)
	if texture_rect.texture != null:
		_assert_true(texture_rect.texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])
	return texture_rect


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
	return null


func _assert_label(root_node: Node, node_name: String, message: String) -> Label:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Label:
		return node as Label
	_failures.append("%s should be a Label" % node_name)
	return null


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
		print("DAILY TASK OVERLAY TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("DAILY TASK OVERLAY TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear daily task test save: %s" % error)
