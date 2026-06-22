extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	await process_frame
	await physics_frame

	battle.set("coins", 65)
	battle.call("_update_hud")
	await process_frame

	var tabby_button: Button = _assert_button(battle, "SelectTowerTabbySlowCatButton", "tabby tower card should expose a transparent button")
	if tabby_button != null:
		tabby_button.emit_signal("pressed")
	await process_frame

	_assert_missing(battle, "BattleTowerSelectionGuidance", "unaffordable tabby selection should not show placement guidance yet")
	_assert_true(str(battle.get("_selected_tower_id")) == "tabby_slow_cat", "unaffordable tabby selection should stay selected")

	battle.set("coins", 75)
	battle.call("_update_hud")
	await process_frame

	var guidance: Control = _assert_control(battle, "BattleTowerSelectionGuidance", "tabby should show Image2 placement guidance as soon as it becomes affordable")
	if guidance != null:
		_assert_true(str(guidance.get_meta("tower_id", "")) == "tabby_slow_cat", "recovered guidance should point at the selected tabby tower")
		_assert_true(bool(guidance.get_meta("image2_tower_selection_guidance", false)), "recovered guidance should use the Image2 selection guidance")
	var shortage_stamp: TextureRect = _find_by_name(battle, "TowerCardTabbySlowCatInsufficientFishState") as TextureRect
	if shortage_stamp != null:
		_assert_true(not shortage_stamp.visible, "tabby shortage stamp should clear when the tower becomes affordable")

	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "guided build slot should remain tappable after affordability recovery")
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	await process_frame

	_assert_missing(battle, "BattleTowerSelectionGuidance", "recovered guidance should disappear after building")
	_assert_true(int(battle.towers.size()) == 1, "affordability recovery should still allow building one tower")
	if not battle.towers.is_empty():
		var tower: Node = battle.towers[0]
		_assert_true(str(tower.get("tower_id")) == "tabby_slow_cat", "recovered guidance build should use the selected tabby tower")

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
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _finish() -> void:
	if _failures.is_empty():
		print("BATTLE TOWER AFFORDABILITY RECOVERY GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE TOWER AFFORDABILITY RECOVERY GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)
