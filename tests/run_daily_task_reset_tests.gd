extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_daily_task_reset_test_save.json"

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

	var first_day: Node = _new_ready_instance(scene, "2026-06-15")
	await process_frame
	_make_first_task_ready(first_day)
	var first_day_fish: int = int(first_day.get("_total_fish"))
	await _open_daily_tasks(first_day)
	var first_claim: Button = _assert_button(first_day, "ClaimDailyTaskFirstClearButton", "first day daily task claim button should exist")
	if first_claim != null:
		_assert_true(not first_claim.disabled, "first day completed daily task should be claimable")
		first_claim.emit_signal("pressed")
		await process_frame
	_assert_true(int(first_day.get("_total_fish")) == first_day_fish + 30, "first day daily task should grant fish")

	await _open_daily_tasks(first_day)
	var same_day_claim: Button = _assert_button(first_day, "ClaimDailyTaskFirstClearButton", "same day claim button should exist")
	if same_day_claim != null:
		_assert_true(same_day_claim.disabled, "same day daily task should stay claimed")
		same_day_claim.emit_signal("pressed")
		await process_frame
	_assert_true(int(first_day.get("_total_fish")) == first_day_fish + 30, "same day daily task should not grant fish twice")

	first_day.queue_free()
	await process_frame

	var reloaded_same_day: Node = _new_ready_instance(scene, "2026-06-15")
	await process_frame
	_make_first_task_ready(reloaded_same_day)
	await _open_daily_tasks(reloaded_same_day)
	var reloaded_claim: Button = _assert_button(reloaded_same_day, "ClaimDailyTaskFirstClearButton", "reloaded same day claim button should exist")
	if reloaded_claim != null:
		_assert_true(reloaded_claim.disabled, "same day daily task claim should persist after reload")
	reloaded_same_day.queue_free()
	await process_frame

	var next_day: Node = _new_ready_instance(scene, "2026-06-16")
	await process_frame
	_make_first_task_ready(next_day)
	var next_day_fish: int = int(next_day.get("_total_fish"))
	await _open_daily_tasks(next_day)
	var next_day_claim: Button = _assert_button(next_day, "ClaimDailyTaskFirstClearButton", "next day claim button should exist")
	if next_day_claim != null:
		_assert_true(not next_day_claim.disabled, "next day daily task should reset to claimable")
		next_day_claim.emit_signal("pressed")
		await process_frame
	_assert_true(int(next_day.get("_total_fish")) == next_day_fish + 30, "next day daily task should grant fish again")

	var raw_claims: Variant = next_day.get("_claimed_daily_tasks_by_date")
	if raw_claims is Dictionary:
		var claims_by_date: Dictionary = raw_claims as Dictionary
		_assert_true(claims_by_date.has("2026-06-15"), "daily task save should keep the first day claim bucket")
		_assert_true(claims_by_date.has("2026-06-16"), "daily task save should keep the next day claim bucket")
	else:
		_failures.append("daily task claims should be saved by date")

	next_day.queue_free()
	_finish()


func _new_ready_instance(scene: PackedScene, date_key: String) -> Node:
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	instance.set("_reward_date_override", date_key)
	root.add_child(instance)
	return instance


func _make_first_task_ready(instance: Node) -> void:
	instance.set("_best_stars_by_level", {1: 3})
	instance.call("_recalculate_best_stars")


func _open_daily_tasks(instance: Node) -> void:
	var existing: Node = _find_by_name(instance, "DailyTaskOverlay")
	if existing != null:
		existing.queue_free()
		await process_frame
	var task_button: Button = _assert_button(instance, "DailyTaskButton", "main menu should expose daily task entry")
	if task_button != null:
		task_button.emit_signal("pressed")
		await process_frame


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
	return null


func _assert_exists(root_node: Node, node_name: String, message: String) -> Node:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
	return node


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
		print("DAILY TASK RESET TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("DAILY TASK RESET TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear daily task reset test save: %s" % error)
