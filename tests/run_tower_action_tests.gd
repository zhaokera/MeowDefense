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

	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "battle should expose first build slot button")
	if build_button == null:
		_finish(battle)
		return
	build_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	_assert_true(int(battle.towers.size()) == 1, "first build slot should build one tower")
	var tower: Node2D = battle.towers[0] as Node2D
	var coins_after_build: int = int(battle.coins)
	build_button = _assert_button(battle, "BuildSlot1Button", "occupied build slot button should remain accessible")
	if build_button != null:
		_assert_true(not build_button.disabled, "occupied build slot button should open tower actions instead of disabling input")
		build_button.emit_signal("pressed")
	await process_frame

	_assert_exists(battle, "TowerActionOverlay", "pressing an occupied tower slot should open tower actions")
	_assert_texture_node(battle, "TowerActionDesignPanel", "res://assets/generated/ui/tower_action_panel.png", "tower action panel should use an Image2 panel asset")
	_assert_button(battle, "UpgradeTowerButton", "tower action panel should expose upgrade")
	_assert_button(battle, "SellTowerButton", "tower action panel should expose sell")
	_assert_button(battle, "CloseTowerActionButton", "tower action panel should expose close")
	_assert_missing(battle, "TowerActionPanel", "tower actions should not use the old code-drawn panel")

	var upgrade_button: Button = _assert_button(battle, "UpgradeTowerButton", "tower action panel should upgrade")
	if upgrade_button != null and tower != null:
		upgrade_button.emit_signal("pressed")
		await process_frame
		_assert_true(int(tower.get("level")) == 2, "upgrade should increase tower level")
		_assert_true(int(battle.coins) < coins_after_build, "upgrade should spend fish")

	var sell_button: Button = _assert_button(battle, "SellTowerButton", "tower action panel should sell")
	if sell_button != null:
		sell_button.emit_signal("pressed")
		await process_frame
		_assert_true(int(battle.towers.size()) == 0, "selling should remove the tower")
		_assert_true(int(battle.coins) > 0, "selling should return some fish")
		build_button = _assert_button(battle, "BuildSlot1Button", "sold slot should be buildable again")
		if build_button != null:
			_assert_true(not build_button.disabled, "sold slot should not stay disabled")

	_finish(battle)


func _finish(battle: Node) -> void:
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	if _failures.is_empty():
		print("TOWER ACTION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("TOWER ACTION TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_exists(root_node: Node, node_name: String, message: String) -> Node:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
	return node


func _assert_missing(root_node: Node, node_name: String, message: String) -> void:
	if _find_by_name(root_node, node_name) != null:
		_failures.append(message)


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
	return null


func _assert_texture_node(root_node: Node, node_name: String, expected_path: String, message: String) -> void:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return
	if not node is TextureRect:
		_failures.append("%s should be a TextureRect" % node_name)
		return
	var texture_rect: TextureRect = node as TextureRect
	if texture_rect.texture == null:
		_failures.append("%s should have a texture" % node_name)
		return
	if texture_rect.texture.resource_path != expected_path:
		_failures.append("%s should use %s" % [node_name, expected_path])


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
