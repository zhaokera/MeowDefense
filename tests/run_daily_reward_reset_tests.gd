extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_daily_reward_reset_test_save.json"

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

	var instance: Node = _new_main_instance(scene, "2026-06-15")
	await process_frame
	var first_day_fish: int = int(instance.get("_total_fish"))
	await _open_reward(instance)
	var first_claim: Button = _assert_button(instance, "ClaimRewardButton", "first day reward claim button should exist")
	if first_claim != null:
		_assert_true(not first_claim.disabled, "first day reward should be claimable")
		first_claim.emit_signal("pressed")
		await process_frame
	_assert_true(int(instance.get("_total_fish")) == first_day_fish + 20, "first day claim should grant 20 fish")
	_assert_true(str(instance.get("_daily_reward_claimed_on")) == "2026-06-15", "first day claim should store the claim date")
	_assert_true(_as_int(instance.get("_daily_reward_streak")) == 1, "first day claim should start a streak")

	await _open_reward(instance)
	var same_day_claim: Button = _assert_button(instance, "ClaimRewardButton", "same day claim button should exist")
	if same_day_claim != null:
		_assert_true(same_day_claim.disabled, "same day reward should be disabled after claim")
		same_day_claim.emit_signal("pressed")
		await process_frame
	_assert_true(int(instance.get("_total_fish")) == first_day_fish + 20, "same day claim should not grant fish twice")

	instance.queue_free()
	await process_frame

	var reloaded: Node = _new_main_instance(scene, "2026-06-15")
	await process_frame
	await _open_reward(reloaded)
	var reloaded_claim: Button = _assert_button(reloaded, "ClaimRewardButton", "reloaded same day claim button should exist")
	if reloaded_claim != null:
		_assert_true(reloaded_claim.disabled, "same day claimed state should persist after reload")
	reloaded.queue_free()
	await process_frame

	var next_day: Node = _new_main_instance(scene, "2026-06-16")
	await process_frame
	var next_day_fish: int = int(next_day.get("_total_fish"))
	await _open_reward(next_day)
	var next_day_claim: Button = _assert_button(next_day, "ClaimRewardButton", "next day claim button should exist")
	if next_day_claim != null:
		_assert_true(not next_day_claim.disabled, "next day reward should become claimable again")
		next_day_claim.emit_signal("pressed")
		await process_frame
	_assert_true(int(next_day.get("_total_fish")) == next_day_fish + 20, "next day claim should grant another 20 fish")
	_assert_true(str(next_day.get("_daily_reward_claimed_on")) == "2026-06-16", "next day claim should update the claim date")
	_assert_true(_as_int(next_day.get("_daily_reward_streak")) == 2, "consecutive next day claim should increase the streak")

	await _open_reward(next_day)
	var streak_label: Label = _assert_label(next_day, "RewardStreakLabel", "reward overlay should show the current streak")
	if streak_label != null:
		_assert_true(streak_label.text.contains("2"), "streak label should show the second day streak")

	next_day.queue_free()
	_finish()


func _new_main_instance(scene: PackedScene, reward_date: String) -> Node:
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	instance.set("_reward_date_override", reward_date)
	root.add_child(instance)
	return instance


func _open_reward(instance: Node) -> void:
	var existing: Node = _find_by_name(instance, "RewardOverlay")
	if existing != null:
		existing.queue_free()
	await process_frame
	var reward_button: Button = _assert_button(instance, "DailyRewardButton", "main menu should expose daily reward")
	if reward_button != null:
		reward_button.emit_signal("pressed")
		await process_frame


func _assert_label(root_node: Node, node_name: String, message: String) -> Label:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Label:
		return node as Label
	_failures.append("%s should be a Label" % node_name)
	return null


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


func _as_int(value: Variant) -> int:
	if value is int or value is float:
		return int(value)
	return 0


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
		print("DAILY REWARD RESET TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("DAILY REWARD RESET TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear daily reward reset test save: %s" % error)
