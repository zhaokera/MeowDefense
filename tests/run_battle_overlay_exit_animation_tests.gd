extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await _assert_tower_action_exit_animation()
	await _assert_pause_settings_exit_animation()
	await _assert_pause_menu_resume_exit_animation()
	_finish(null)


func _assert_tower_action_exit_animation() -> void:
	var battle: Node2D = await _new_battle()
	var build_button: Button = _find_by_name(battle, "BuildSlot1Button") as Button
	if build_button == null:
		_failures.append("build slot button should exist for tower action exit")
		_finish_battle(battle)
		return
	build_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	build_button = _find_by_name(battle, "BuildSlot1Button") as Button
	if build_button == null:
		_failures.append("occupied build slot button should still exist")
		_finish_battle(battle)
		return
	build_button.emit_signal("pressed")
	await process_frame
	await _assert_overlay_exit_animation(battle, "TowerActionOverlay", "CloseTowerActionButton", "tower action")
	_finish_battle(battle)


func _assert_pause_settings_exit_animation() -> void:
	var battle: Node2D = await _new_battle()
	var pause_button: Button = _find_by_name(battle, "PauseButton") as Button
	if pause_button == null:
		_failures.append("pause button should exist for pause settings exit")
		_finish_battle(battle)
		return
	pause_button.emit_signal("pressed")
	await process_frame
	var settings_button: Button = _find_by_name(battle, "PauseSettingsButton") as Button
	if settings_button == null:
		_failures.append("pause settings button should exist")
		_finish_battle(battle)
		return
	settings_button.emit_signal("pressed")
	await process_frame
	await _assert_overlay_exit_animation(battle, "PauseSettingsOverlay", "ClosePauseSettingsButton", "pause settings")
	var resume_button: Button = _find_by_name(battle, "ResumeButton") as Button
	if resume_button != null:
		_assert_true(resume_button.visible, "pause menu controls should return after pause settings exits")
	_finish_battle(battle)


func _assert_pause_menu_resume_exit_animation() -> void:
	var battle: Node2D = await _new_battle()
	var pause_button: Button = _find_by_name(battle, "PauseButton") as Button
	if pause_button == null:
		_failures.append("pause button should exist for pause menu exit")
		_finish_battle(battle)
		return
	pause_button.emit_signal("pressed")
	await process_frame
	var overlay: Control = _find_by_name(battle, "PauseMenuOverlay") as Control
	var resume_button: Button = _find_by_name(battle, "ResumeButton") as Button
	if overlay == null:
		_failures.append("pause menu overlay should exist before resume")
		_finish_battle(battle)
		return
	if resume_button == null:
		_failures.append("resume button should exist before resume")
		_finish_battle(battle)
		return
	resume_button.emit_signal("pressed")
	_assert_true(not paused, "resume should unpause battle immediately")
	_assert_true(is_instance_valid(overlay), "pause menu overlay should remain alive for exit animation immediately after resume")
	if is_instance_valid(overlay):
		_assert_true(overlay.get_meta("image2_overlay_exit_animation", false), "pause menu overlay should mark Image2 exit animation metadata")
		_assert_true(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "pause menu overlay should stop catching input while exiting")
		_assert_true(overlay.modulate.a < 1.0, "pause menu overlay should start fading out immediately during exit animation")
	_assert_true(resume_button.disabled, "resume button should disable during exit animation")
	for _frame: int in range(45):
		await process_frame
	_assert_true(_find_by_name(battle, "PauseMenuOverlay") == null, "pause menu overlay should be removed after exit animation")
	_finish_battle(battle)


func _assert_overlay_exit_animation(battle: Node, overlay_name: String, close_button_name: String, label: String) -> void:
	var overlay: Control = _find_by_name(battle, overlay_name) as Control
	var close_button: Button = _find_by_name(battle, close_button_name) as Button
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
	_assert_true(_find_by_name(battle, overlay_name) == null, "%s overlay should be removed after exit animation" % label)


func _new_battle() -> Node2D:
	paused = false
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame
	return battle


func _finish_battle(battle: Node) -> void:
	paused = false
	if battle != null and is_instance_valid(battle):
		battle.queue_free()


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


func _finish(battle: Node) -> void:
	_finish_battle(battle)
	if _failures.is_empty():
		print("BATTLE OVERLAY EXIT ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE OVERLAY EXIT ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
