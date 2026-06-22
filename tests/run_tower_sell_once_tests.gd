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

	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "battle should expose the first build slot button")
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	_assert_true(int(battle.towers.size()) == 1, "test setup should build one tower")
	var tower: Node2D = battle.towers[0] as Node2D if not battle.towers.is_empty() else null
	var coins_after_build: int = int(battle.get("coins"))
	var expected_refund: int = int(battle.call("_tower_sell_refund", tower)) if tower != null else 0

	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame

	var sell_button: Button = _assert_button(battle, "SellTowerButton", "tower action panel should expose sell")
	if sell_button != null:
		sell_button.emit_signal("pressed")
		sell_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	_assert_true(int(battle.towers.size()) == 0, "repeat sell callbacks should leave the tower removed")
	_assert_true(int(battle.get("coins")) == coins_after_build + expected_refund, "repeat sell callbacks should refund fish once")
	_assert_exists(battle, "TowerSellFeedback1", "first sell callback should show Image2 sell burst")
	_assert_missing(battle, "TowerSellFeedback2", "repeat sell callback should not create a second Image2 sell burst")
	_assert_exists(battle, "TowerSellRefundFlyFish1", "first sell callback should fly one Image2 refund chip")
	_assert_missing(battle, "TowerSellRefundFlyFish2", "repeat sell callback should not fly a second refund chip")

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
		print("TOWER SELL ONCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("TOWER SELL ONCE TESTS FAIL: %d" % _failures.size())
		quit(1)
