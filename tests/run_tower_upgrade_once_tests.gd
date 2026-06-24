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

	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "battle should expose first build slot")
	if build_button == null:
		_finish(battle)
		return
	build_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	_assert_true(int(battle.towers.size()) == 1, "setup should build one tower")
	var tower: Node2D = battle.towers[0] as Node2D if not battle.towers.is_empty() else null
	if tower == null:
		_finish(battle)
		return
	battle.set("coins", 500)
	var level_before: int = int(tower.get("level"))
	var upgrade_cost: int = int(tower.get("upgrade_cost"))
	var coins_before_upgrade: int = int(battle.get("coins"))

	build_button = _assert_button(battle, "BuildSlot1Button", "occupied build slot should remain tappable")
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame

	var upgrade_button: Button = _assert_button(battle, "UpgradeTowerButton", "tower action overlay should expose upgrade")
	if upgrade_button != null:
		upgrade_button.emit_signal("pressed")
		upgrade_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	_assert_true(int(tower.get("level")) == level_before + 1, "repeat upgrade callbacks in one frame should increase tower level once")
	_assert_true(int(battle.get("coins")) == coins_before_upgrade - upgrade_cost, "repeat upgrade callbacks in one frame should spend fish once")
	_assert_prefixed_count(battle, "TowerUpgradeFeedback", 1, "repeat upgrade callbacks should create one Image2 upgrade burst")
	_assert_prefixed_count(battle, "TowerUpgradeSpendFish", 1, "repeat upgrade callbacks should create one Image2 spend fly chip")

	_finish(battle)


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


func _finish(battle: Node) -> void:
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	if _failures.is_empty():
		print("TOWER UPGRADE ONCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("TOWER UPGRADE ONCE TESTS FAIL: %d" % _failures.size())
		quit(1)
