extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")
const BASE_DAMAGE_ASSET_PATH := "res://assets/generated/ui/base_damage_warning_burst.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var before_hp: int = int(battle.get("base_hp"))
	var enemy: Node2D = EnemyScript.new()
	enemy.set("base_damage", 2)
	battle.enemies.append(enemy)
	root.add_child(enemy)

	battle.call("_on_enemy_reached_goal", enemy)
	await process_frame
	await physics_frame

	_assert_true(int(battle.get("base_hp")) == before_hp - 2, "enemy reaching the base should reduce base hp by its damage")
	_assert_base_damage_feedback(battle, "base damage should show Image2 warning feedback")

	battle.queue_free()
	_finish()


func _assert_base_damage_feedback(battle: Node, message: String) -> void:
	var node: Node = _assert_exists(battle, "BaseDamageFeedback", message)
	if node == null:
		return
	if not node is TextureRect:
		_failures.append("BaseDamageFeedback should be a TextureRect")
		return
	var texture_rect: TextureRect = node as TextureRect
	if texture_rect.texture == null:
		_failures.append("BaseDamageFeedback should have a texture")
		return
	_assert_true(texture_rect.texture.resource_path == BASE_DAMAGE_ASSET_PATH, "BaseDamageFeedback should use %s" % BASE_DAMAGE_ASSET_PATH)
	var label: Node = _assert_exists(node, "BaseDamageFeedbackLabel", "base damage feedback should include dynamic damage text")
	if label is Label:
		_assert_true((label as Label).text.contains("-2"), "base damage feedback should show the damage amount")


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
		print("BASE DAMAGE FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BASE DAMAGE FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
