extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await _assert_enemy_defeat_reward_is_paid_once()
	await _assert_enemy_base_damage_is_applied_once()
	_finish()


func _assert_enemy_defeat_reward_is_paid_once() -> void:
	var battle: Node2D = await _new_battle()
	if battle == null:
		return
	var before_coins: int = int(battle.get("coins"))
	var enemy: Node2D = EnemyScript.new()
	enemy.set("reward", 7)
	enemy.global_position = Vector2(530, 338)
	battle.enemies.append(enemy)
	battle.add_child(enemy)

	battle.call("_on_enemy_defeated", enemy)
	battle.call("_on_enemy_defeated", enemy)
	await process_frame
	await physics_frame

	_assert_true(int(battle.get("coins")) == before_coins + 7, "duplicate defeat callbacks should pay fish once")
	_assert_exists(battle, "EnemyRewardFeedback1", "first enemy defeat should show Image2 reward feedback")
	_assert_missing(battle, "EnemyRewardFeedback2", "duplicate defeat callback should not create a second reward feedback")
	_assert_exists(battle, "BattleRewardFlyFish1", "first enemy defeat should fly one Image2 fish chip")
	_assert_missing(battle, "BattleRewardFlyFish2", "duplicate defeat callback should not fly a second fish chip")
	_cleanup_battle(battle)


func _assert_enemy_base_damage_is_applied_once() -> void:
	var battle: Node2D = await _new_battle()
	if battle == null:
		return
	var before_hp: int = int(battle.get("base_hp"))
	var enemy: Node2D = EnemyScript.new()
	enemy.set("base_damage", 2)
	enemy.global_position = Vector2(1040, 360)
	battle.enemies.append(enemy)
	battle.add_child(enemy)

	battle.call("_on_enemy_reached_goal", enemy)
	battle.call("_on_enemy_reached_goal", enemy)
	await process_frame
	await physics_frame

	_assert_true(int(battle.get("base_hp")) == before_hp - 2, "duplicate reached-goal callbacks should damage the base once")
	_assert_exists(battle, "BaseDamageFeedback", "first reached-goal callback should show Image2 base damage feedback")
	_cleanup_battle(battle)


func _new_battle() -> Node2D:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame
	return battle


func _cleanup_battle(battle: Node) -> void:
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	await process_frame


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
		print("ENEMY OUTCOME ONCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ENEMY OUTCOME ONCE TESTS FAIL: %d" % _failures.size())
		quit(1)
