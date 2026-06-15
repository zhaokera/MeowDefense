extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const SHORTAGE_ASSET_PATH := "res://assets/generated/ui/battle_resource_shortage_burst.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await _test_build_shortage_feedback()
	await _test_upgrade_shortage_feedback()
	_finish()


func _test_build_shortage_feedback() -> void:
	var battle: Node2D = _fresh_battle()
	await process_frame
	await physics_frame

	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "battle should expose the first build slot")
	battle.set("coins", 0)
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	_assert_true(int(battle.towers.size()) == 0, "insufficient fish should not build a tower")
	_assert_true(int(battle.get("coins")) == 0, "insufficient build should not spend fish")
	_assert_resource_feedback(battle, "insufficient build should show Image2 resource feedback")
	battle.queue_free()


func _test_upgrade_shortage_feedback() -> void:
	var battle: Node2D = _fresh_battle()
	await process_frame
	await physics_frame

	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "battle should expose the first build slot")
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	_assert_true(int(battle.towers.size()) == 1, "setup should build one tower before testing upgrade shortage")
	var tower: Node2D = battle.towers[0] as Node2D if int(battle.towers.size()) > 0 else null
	var starting_level: int = int(tower.get("level")) if tower != null else 0
	battle.set("coins", 0)

	build_button = _assert_button(battle, "BuildSlot1Button", "occupied slot should remain tappable")
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame
	var upgrade_button: Button = _assert_button(battle, "UpgradeTowerButton", "tower action overlay should expose upgrade")
	if upgrade_button != null:
		upgrade_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	if tower != null:
		_assert_true(int(tower.get("level")) == starting_level, "insufficient upgrade should keep tower level unchanged")
	_assert_true(int(battle.get("coins")) == 0, "insufficient upgrade should not spend fish")
	_assert_resource_feedback(battle, "insufficient upgrade should show Image2 resource feedback")
	battle.queue_free()


func _fresh_battle() -> Node2D:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	return battle


func _assert_resource_feedback(battle: Node, message: String) -> void:
	var node: Node = _assert_exists(battle, "BattleResourceFeedback", message)
	if node == null:
		return
	if not node is TextureRect:
		_failures.append("BattleResourceFeedback should be a TextureRect")
		return
	var texture_rect: TextureRect = node as TextureRect
	if texture_rect.texture == null:
		_failures.append("BattleResourceFeedback should have a texture")
		return
	_assert_true(texture_rect.texture.resource_path == SHORTAGE_ASSET_PATH, "BattleResourceFeedback should use %s" % SHORTAGE_ASSET_PATH)


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
		print("BATTLE RESOURCE FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE RESOURCE FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
