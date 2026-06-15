extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const ENEMY_SPAWN_ASSET_PATH := "res://assets/generated/effects/enemy_spawn_mouse_dust.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var enemy_count_before: int = battle.enemies.size()
	battle.call("_spawn_enemy", "mouse_basic")
	await process_frame
	await physics_frame

	_assert_true(battle.enemies.size() == enemy_count_before + 1, "spawning should add one enemy")
	_assert_enemy_spawn_feedback(battle, "enemy spawn should show Image2 entrance feedback")

	battle.queue_free()
	_finish()


func _assert_enemy_spawn_feedback(battle: Node, message: String) -> void:
	var node: Node = _assert_exists(battle, "EnemySpawnFeedback1", message)
	if node == null:
		return
	if not node is Sprite2D and not node is TextureRect:
		_failures.append("EnemySpawnFeedback1 should be a Sprite2D or TextureRect")
		return
	var texture: Texture2D = null
	if node is Sprite2D:
		texture = (node as Sprite2D).texture
	elif node is TextureRect:
		texture = (node as TextureRect).texture
	_assert_true(texture != null, "EnemySpawnFeedback1 should have a texture")
	if texture != null:
		_assert_true(texture.resource_path == ENEMY_SPAWN_ASSET_PATH, "EnemySpawnFeedback1 should use %s" % ENEMY_SPAWN_ASSET_PATH)
	if node is Node2D:
		var effect: Node2D = node as Node2D
		_assert_true(effect.global_position.x >= 56.0, "EnemySpawnFeedback1 should be clamped inside the visible play area")


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
		print("ENEMY SPAWN FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ENEMY SPAWN FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
