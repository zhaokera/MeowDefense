extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_daily_reward_claimed_task_guidance_test_save.json"
const TASK_BADGE_PATH := "res://assets/generated/ui/daily_task_progress_level_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(TASK_BADGE_PATH, "claimed reward task guidance should use a project-bound Image2 daily-task badge")

	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish()
		return
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	instance.set("_reward_date_override", "2026-06-20")
	instance.set("_daily_reward_claimed_on", "2026-06-20")
	instance.set("_daily_reward_claimed", true)
	root.add_child(instance)
	await process_frame
	instance.set("_daily_reward_claimed_on", "2026-06-20")
	instance.set("_daily_reward_claimed", true)

	var reward_button: Button = _assert_button(instance, "DailyRewardButton", "main menu should expose daily reward")
	if reward_button != null:
		reward_button.emit_signal("pressed")
		await process_frame

	var overlay: Control = _assert_control(instance, "RewardOverlay", "claimed daily reward should still open reward overlay")
	var claim_button: Button = _assert_button(instance, "ClaimRewardButton", "claimed daily reward should keep the claim hit area")
	if claim_button != null:
		_assert_true(claim_button.disabled, "claimed daily reward claim button should be disabled")
	var guidance: Control = _assert_control(instance, "RewardClaimedDailyTaskGuidance", "claimed daily reward should show a daily-task guidance group")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_reward_claimed_daily_task_guidance", false)), "claimed reward task guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "claimed reward task guidance should not block its route button")
		if claim_button != null:
			_assert_true(
				not guidance.get_global_rect().intersects(claim_button.get_global_rect()),
				"claimed reward task guidance should not overlap the disabled claim button"
			)
	var badge: TextureRect = _assert_texture_node(instance, "RewardClaimedDailyTaskBadge", TASK_BADGE_PATH, "claimed reward task guidance should render the Image2 task badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "claimed reward task badge should not block route button")
	var label: Label = _assert_label(instance, "RewardClaimedDailyTaskLabel", "claimed reward task guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("任务") or label.text.contains("今日"), "claimed reward task guidance should point to daily tasks")
	var route_button: Button = _assert_button(instance, "RewardClaimedDailyTaskButton", "claimed reward task guidance should expose a daily-task route")
	if route_button != null and claim_button != null:
		_assert_true(
			not route_button.get_global_rect().intersects(claim_button.get_global_rect()),
			"claimed reward task route button should not overlap the disabled claim button"
		)
	if overlay != null and route_button != null:
		route_button.emit_signal("pressed")
		_assert_true(bool(overlay.get_meta("image2_overlay_exit_animation", false)), "claimed reward task route should animate the Image2 reward overlay out")
		_assert_true(route_button.disabled, "claimed reward task route should disable while routing")
		_assert_missing(instance, "DailyTaskOverlay", "claimed reward task route should not hard-cut before reward exit")
		await _wait_until_missing(instance, "RewardOverlay")
		await _wait_until_exists(instance, "DailyTaskOverlay")

	_assert_missing(instance, "RewardOverlay", "claimed reward task route should leave reward overlay")
	_assert_exists(instance, "DailyTaskOverlay", "claimed reward task route should open daily tasks")
	_assert_texture_node(
		instance,
		"DailyTaskDesignBackground",
		"res://assets/generated/ui/daily_task_overlay_state_slots_design_reference.png",
		"claimed reward task route should open the Image2 daily task overlay"
	)

	instance.queue_free()
	_finish()


func _assert_file_exists(path: String, message: String) -> void:
	if not FileAccess.file_exists(path):
		_failures.append(message)


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


func _assert_control(root_node: Node, node_name: String, message: String) -> Control:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Control:
		return node as Control
	_failures.append("%s should be a Control" % node_name)
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
	if node == null:
		return null
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) != null:
			return
		await process_frame


func _wait_until_missing(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) == null:
			return
		await process_frame


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("DAILY REWARD CLAIMED TASK GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("DAILY REWARD CLAIMED TASK GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear claimed daily reward task guidance save: %s" % error)
