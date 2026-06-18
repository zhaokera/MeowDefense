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

	var build_button: Button = _find_by_name(battle, "BuildSlot1Button") as Button
	if build_button == null:
		_failures.append("build slot button should exist before sell action")
		_finish(battle)
		return
	build_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	_assert_true(int(battle.towers.size()) == 1, "sell action test should have one built tower")
	var coins_after_build: int = int(battle.coins)

	build_button = _find_by_name(battle, "BuildSlot1Button") as Button
	if build_button == null:
		_failures.append("occupied build slot button should exist before sell action")
		_finish(battle)
		return
	build_button.emit_signal("pressed")
	await process_frame

	var overlay: Control = _find_by_name(battle, "TowerActionOverlay") as Control
	var sell_button: Button = _find_by_name(battle, "SellTowerButton") as Button
	if overlay == null:
		_failures.append("tower action overlay should exist before sell action")
		_finish(battle)
		return
	if sell_button == null:
		_failures.append("sell button should exist before sell action")
		_finish(battle)
		return

	sell_button.emit_signal("pressed")
	_assert_true(int(battle.towers.size()) == 0, "selling should remove the tower immediately")
	_assert_true(int(battle.coins) > coins_after_build, "selling should refund fish immediately")
	_assert_true(is_instance_valid(overlay), "tower action overlay should remain alive for sell exit animation")
	if is_instance_valid(overlay):
		_assert_true(overlay.get_meta("image2_overlay_exit_animation", false), "tower action overlay should mark Image2 sell exit animation metadata")
		_assert_true(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "tower action overlay should ignore input during sell exit animation")
		_assert_true(overlay.modulate.a < 1.0, "tower action overlay should start fading during sell exit animation")
	_assert_true(sell_button.disabled, "sell button should disable during sell exit animation")
	build_button = _find_by_name(battle, "BuildSlot1Button") as Button
	if build_button != null:
		_assert_true(not build_button.disabled, "sold slot should be buildable while sell exit animation plays")

	for _frame: int in range(45):
		await process_frame
	_assert_true(_find_by_name(battle, "TowerActionOverlay") == null, "tower action overlay should be removed after sell exit animation")

	_finish(battle)


func _finish(battle: Node) -> void:
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	if _failures.is_empty():
		print("TOWER SELL ACTION EXIT ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("TOWER SELL ACTION EXIT ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)


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
