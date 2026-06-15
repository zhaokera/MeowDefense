extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const TOWER_UPGRADE_ASSET_PATH := "res://assets/generated/effects/tower_upgrade_cat_starburst.png"

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

	_assert_true(int(battle.towers.size()) == 1, "test setup should build a tower")
	var tower: Node2D = battle.towers[0] as Node2D if not battle.towers.is_empty() else null
	var level_before: int = int(tower.get("level")) if tower != null else 0
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame

	var upgrade_button: Button = _assert_button(battle, "UpgradeTowerButton", "tower action panel should expose upgrade")
	if upgrade_button != null:
		upgrade_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	if tower != null:
		_assert_true(int(tower.get("level")) == level_before + 1, "upgrade should increase tower level")
	_assert_tower_upgrade_feedback(battle, "successful tower upgrade should show Image2 upgrade feedback")

	battle.queue_free()
	_finish()


func _assert_tower_upgrade_feedback(battle: Node, message: String) -> void:
	var node: Node = _assert_exists(battle, "TowerUpgradeFeedback1", message)
	if node == null:
		return
	if not node is Sprite2D and not node is TextureRect:
		_failures.append("TowerUpgradeFeedback1 should be a Sprite2D or TextureRect")
		return
	var texture: Texture2D = null
	if node is Sprite2D:
		texture = (node as Sprite2D).texture
	elif node is TextureRect:
		texture = (node as TextureRect).texture
	_assert_true(texture != null, "TowerUpgradeFeedback1 should have a texture")
	if texture != null:
		_assert_true(texture.resource_path == TOWER_UPGRADE_ASSET_PATH, "TowerUpgradeFeedback1 should use %s" % TOWER_UPGRADE_ASSET_PATH)


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
		print("TOWER UPGRADE FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("TOWER UPGRADE FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
