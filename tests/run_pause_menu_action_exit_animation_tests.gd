extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await _assert_pause_restart_exit_animation()
	await _assert_pause_quit_exit_animation()
	_finish(null)


func _assert_pause_restart_exit_animation() -> void:
	var battle: Node2D = await _new_battle()
	var build_button: Button = _find_by_name(battle, "BuildSlot1Button") as Button
	if build_button == null:
		_failures.append("build slot button should exist before restart action")
		_finish_battle(battle)
		return
	build_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	_assert_true(int(battle.towers.size()) == 1, "restart action test should have one built tower")

	var pause_button: Button = _find_by_name(battle, "PauseButton") as Button
	if pause_button == null:
		_failures.append("pause button should exist before restart action")
		_finish_battle(battle)
		return
	pause_button.emit_signal("pressed")
	await process_frame

	var overlay: Control = _find_by_name(battle, "PauseMenuOverlay") as Control
	var restart_button: Button = _find_by_name(battle, "RestartBattleButton") as Button
	if overlay == null:
		_failures.append("pause menu overlay should exist before restart")
		_finish_battle(battle)
		return
	if restart_button == null:
		_failures.append("restart button should exist before restart")
		_finish_battle(battle)
		return

	restart_button.emit_signal("pressed")
	_assert_true(not paused, "restart action should unpause battle immediately for the exit animation")
	_assert_true(int(battle.towers.size()) == 1, "restart should wait for the pause menu exit animation before resetting the level")
	_assert_pause_overlay_exiting(overlay, restart_button, "restart")
	for _frame: int in range(45):
		await process_frame
	_assert_true(_find_by_name(battle, "PauseMenuOverlay") == null, "pause menu should be removed after restart exit animation")
	_assert_true(int(battle.towers.size()) == 0, "restart should reset the battle after the exit animation")
	_assert_true(_find_by_name(battle, "BuildSlot1Button") != null, "restarted battle should rebuild the HUD")
	_finish_battle(battle)


func _assert_pause_quit_exit_animation() -> void:
	var battle: Node2D = await _new_battle()
	var exit_state := {"requested": false}
	battle.exit_to_levels_requested.connect(func() -> void:
		exit_state["requested"] = true
	)

	var pause_button: Button = _find_by_name(battle, "PauseButton") as Button
	if pause_button == null:
		_failures.append("pause button should exist before quit action")
		_finish_battle(battle)
		return
	pause_button.emit_signal("pressed")
	await process_frame

	var overlay: Control = _find_by_name(battle, "PauseMenuOverlay") as Control
	var quit_button: Button = _find_by_name(battle, "QuitToLevelsButton") as Button
	if overlay == null:
		_failures.append("pause menu overlay should exist before quit")
		_finish_battle(battle)
		return
	if quit_button == null:
		_failures.append("quit button should exist before quit")
		_finish_battle(battle)
		return

	quit_button.emit_signal("pressed")
	_assert_true(not paused, "quit action should unpause battle immediately for the exit animation")
	_assert_true(not bool(exit_state["requested"]), "quit should wait for the pause menu exit animation before routing to levels")
	_assert_pause_overlay_exiting(overlay, quit_button, "quit")
	for _frame: int in range(45):
		await process_frame
	_assert_true(_find_by_name(battle, "PauseMenuOverlay") == null, "pause menu should be removed after quit exit animation")
	_assert_true(bool(exit_state["requested"]), "quit should request level select after the exit animation")
	_finish_battle(battle)


func _assert_pause_overlay_exiting(overlay: Control, button: Button, action_label: String) -> void:
	_assert_true(is_instance_valid(overlay), "%s pause menu should remain alive for exit animation immediately after press" % action_label)
	if is_instance_valid(overlay):
		_assert_true(overlay.get_meta("image2_overlay_exit_animation", false), "%s pause menu should mark Image2 exit animation metadata" % action_label)
		_assert_true(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "%s pause menu should ignore input while exiting" % action_label)
		_assert_true(overlay.modulate.a < 1.0, "%s pause menu should start fading out immediately during exit animation" % action_label)
	_assert_true(button.disabled, "%s button should disable during pause menu exit animation" % action_label)


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
		print("PAUSE MENU ACTION EXIT ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("PAUSE MENU ACTION EXIT ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
