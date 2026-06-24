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

	var pause_button: Button = _assert_button(battle, "PauseButton", "battle HUD should expose pause")
	if pause_button != null:
		pause_button.emit_signal("pressed")
		await process_frame

	var settings_button: Button = _assert_button(battle, "PauseSettingsButton", "pause menu should expose settings")
	if settings_button != null:
		settings_button.emit_signal("pressed")
		await process_frame
		settings_button.emit_signal("pressed")

		_assert_prefixed_count(battle, "PauseSettingsOverlay", 1, "repeated pause settings opens should keep one overlay alive")
		_assert_prefixed_count(battle, "PauseSettingsDesignPanel", 1, "repeated pause settings opens should keep one Image2 design panel")
		_assert_prefixed_count(battle, "PauseMusicToggle", 1, "repeated pause settings opens should keep one music hit area")
		_assert_prefixed_count(battle, "PauseEffectsToggle", 1, "repeated pause settings opens should keep one effects hit area")
		_assert_prefixed_count(battle, "PauseVolumeSlider", 1, "repeated pause settings opens should keep one volume hit area")
		_assert_true(not settings_button.visible, "pause menu controls should stay hidden while settings overlay is open")

		await process_frame
		_assert_prefixed_count(battle, "PauseSettingsOverlay", 1, "pause settings overlay should remain singular after queued-free cleanup")
		_assert_prefixed_count(battle, "PauseVolumeSlider", 1, "pause settings volume hit area should remain singular after cleanup")

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


func _assert_prefixed_count(root_node: Node, prefix: String, expected: int, message: String) -> void:
	var count := _count_nodes_with_prefix(root_node, prefix)
	if count != expected:
		_failures.append("%s: expected %d, got %d" % [message, expected, count])


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _count_nodes_with_prefix(node: Node, prefix: String) -> int:
	var count := 0
	if String(node.name).begins_with(prefix):
		count += 1
	for child: Node in node.get_children():
		count += _count_nodes_with_prefix(child, prefix)
	return count


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
		print("PAUSE SETTINGS OPEN ONCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		quit(1)
