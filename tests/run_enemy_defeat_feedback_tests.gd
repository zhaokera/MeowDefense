extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")
const ENEMY_DEFEAT_ASSET_PATH := "res://assets/generated/effects/enemy_defeat_mouse_puff.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var enemy: Node2D = EnemyScript.new()
	enemy.set("reward", 7)
	enemy.global_position = Vector2(530, 338)
	var enemy_count_before: int = battle.enemies.size()
	battle.enemies.append(enemy)
	root.add_child(enemy)

	battle.call("_on_enemy_defeated", enemy)
	await process_frame
	await physics_frame

	_assert_true(battle.enemies.size() == enemy_count_before, "defeated enemy should leave the active enemy list")
	_assert_enemy_defeat_feedback(battle, "enemy defeat should show Image2 defeat puff feedback")
	_assert_reward_does_not_cover_defeat_feedback(battle)

	battle.queue_free()
	_finish()


func _assert_enemy_defeat_feedback(battle: Node, message: String) -> void:
	var node: Node = _assert_exists(battle, "EnemyDefeatFeedback1", message)
	if node == null:
		return
	if not node is Sprite2D and not node is TextureRect:
		_failures.append("EnemyDefeatFeedback1 should be a Sprite2D or TextureRect")
		return
	var texture: Texture2D = null
	if node is Sprite2D:
		texture = (node as Sprite2D).texture
	elif node is TextureRect:
		texture = (node as TextureRect).texture
	_assert_true(texture != null, "EnemyDefeatFeedback1 should have a texture")
	if texture != null:
		_assert_true(texture.resource_path == ENEMY_DEFEAT_ASSET_PATH, "EnemyDefeatFeedback1 should use %s" % ENEMY_DEFEAT_ASSET_PATH)


func _assert_reward_does_not_cover_defeat_feedback(battle: Node) -> void:
	var defeat: Node = _assert_exists(battle, "EnemyDefeatFeedback1", "enemy defeat feedback should exist before overlap check")
	var reward: Node = _assert_exists(battle, "EnemyRewardFeedback1", "enemy reward feedback should exist before overlap check")
	if defeat == null or reward == null:
		return
	if not defeat is Sprite2D or not reward is TextureRect:
		return
	var defeat_sprite: Sprite2D = defeat as Sprite2D
	var reward_rect: TextureRect = reward as TextureRect
	_assert_true(
		reward_rect.position.x > defeat_sprite.position.x + 12.0 or reward_rect.position.y + reward_rect.size.y < defeat_sprite.position.y - 10.0,
		"enemy reward feedback should leave the defeat puff readable"
	)


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
		print("ENEMY DEFEAT FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ENEMY DEFEAT FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
