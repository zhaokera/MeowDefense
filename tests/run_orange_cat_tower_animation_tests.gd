extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")
const ORANGE_CAT_SHEET_PATH := "res://assets/generated/towers/orange_cat_tower_sheet.png"

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

	_assert_true(not battle.towers.is_empty(), "test setup should build an orange cat tower")
	var tower: Node2D = battle.towers[0] as Node2D if not battle.towers.is_empty() else null
	var sprite: Sprite2D = _tower_sprite(tower)
	_assert_true(sprite != null, "orange cat tower should expose an animated Sprite2D")
	if sprite != null:
		_assert_true(sprite.texture != null, "orange cat tower sprite should have a texture")
		if sprite.texture != null:
			_assert_true(sprite.texture.resource_path == ORANGE_CAT_SHEET_PATH, "orange cat tower should use %s" % ORANGE_CAT_SHEET_PATH)
		_assert_true(sprite.region_enabled, "orange cat tower should use sprite-sheet regions")
		var idle_rect: Rect2 = sprite.region_rect
		_fire_tower_at_test_enemy(battle, tower)
		await process_frame
		await physics_frame
		_assert_true(sprite.region_rect.position != idle_rect.position, "orange cat tower should switch to a firing animation frame")

	battle.queue_free()
	_finish()


func _fire_tower_at_test_enemy(battle: Node2D, tower: Node2D) -> void:
	if tower == null:
		return
	var enemy: Node2D = EnemyScript.new()
	enemy.set("max_hp", 20.0)
	enemy.set("hp", 20.0)
	enemy.global_position = tower.global_position + Vector2(54, -4)
	battle.enemies.append(enemy)
	var enemy_layer: Node = battle.get_node_or_null("World/Enemies")
	if enemy_layer != null:
		enemy_layer.add_child(enemy)
	else:
		root.add_child(enemy)
	battle.simulate_step(0.12)
	_assert_true(float(enemy.get("hp")) < 20.0, "orange cat tower should fire at the test enemy")


func _tower_sprite(tower: Node) -> Sprite2D:
	if tower == null:
		return null
	var visual_root: Node = _find_by_name(tower, "AnimatedTowerVisual")
	if visual_root == null:
		return null
	return _find_first_sprite(visual_root)


func _find_first_sprite(node: Node) -> Sprite2D:
	if node is Sprite2D:
		return node as Sprite2D
	for child: Node in node.get_children():
		var found: Sprite2D = _find_first_sprite(child)
		if found != null:
			return found
	return null


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


func _finish() -> void:
	if _failures.is_empty():
		print("ORANGE CAT TOWER ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ORANGE CAT TOWER ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
