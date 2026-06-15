extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")
const ENEMY_REWARD_ASSET_PATH := "res://assets/generated/ui/enemy_reward_fish_burst.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var before_coins: int = int(battle.get("coins"))
	var enemy: Node2D = EnemyScript.new()
	enemy.set("reward", 7)
	enemy.global_position = Vector2(530, 338)
	battle.enemies.append(enemy)
	root.add_child(enemy)

	battle.call("_on_enemy_defeated", enemy)
	await process_frame
	await physics_frame

	_assert_true(int(battle.get("coins")) == before_coins + 7, "defeating an enemy should add its fish reward")
	_assert_enemy_reward_feedback(battle, "enemy defeat should show Image2 fish reward feedback")

	battle.queue_free()
	_finish()


func _assert_enemy_reward_feedback(battle: Node, message: String) -> void:
	var node: Node = _assert_exists(battle, "EnemyRewardFeedback1", message)
	if node == null:
		return
	if not node is TextureRect:
		_failures.append("EnemyRewardFeedback1 should be a TextureRect")
		return
	var texture_rect: TextureRect = node as TextureRect
	if texture_rect.texture == null:
		_failures.append("EnemyRewardFeedback1 should have a texture")
		return
	_assert_true(texture_rect.texture.resource_path == ENEMY_REWARD_ASSET_PATH, "EnemyRewardFeedback1 should use %s" % ENEMY_REWARD_ASSET_PATH)
	var label: Node = _assert_exists(node, "EnemyRewardFeedbackLabel", "enemy reward feedback should include dynamic reward text")
	if label is Label:
		_assert_true((label as Label).text.contains("+7"), "enemy reward feedback should show the fish amount")


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
		print("ENEMY REWARD FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ENEMY REWARD FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
