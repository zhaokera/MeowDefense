extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var wave_states: Array = battle.get("_wave_states") as Array
	var first_wave: Dictionary = wave_states[0] as Dictionary
	var remaining_before: int = int(first_wave.get("remaining", 0))
	var rush_button: Button = _assert_button(battle, "RushNextWaveButton", "battle HUD should expose rush-next-wave button")
	if rush_button != null:
		rush_button.emit_signal("pressed")
		rush_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	wave_states = battle.get("_wave_states") as Array
	first_wave = wave_states[0] as Dictionary
	_assert_true(int(battle.enemies.size()) == 1, "repeat rush callbacks in the same moment should spawn one enemy")
	_assert_true(int(first_wave.get("remaining", 0)) == remaining_before - 1, "repeat rush callbacks should advance wave remaining once")
	_assert_exists(battle, "BattleWaveRushFeedback1", "first rush callback should show Image2 rush feedback")
	_assert_missing(battle, "BattleWaveRushFeedback2", "repeat rush callback should not create a second rush feedback")
	_assert_true(float(first_wave.get("next_time", 0.0)) > float(battle.get("elapsed")) + 0.05, "next enemy should remain scheduled for the wave interval")

	battle.queue_free()
	_finish()


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
	if _failures.is_empty():
		print("BATTLE WAVE RUSH ONCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE WAVE RUSH ONCE TESTS FAIL: %d" % _failures.size())
		quit(1)
