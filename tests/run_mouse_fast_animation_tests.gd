extends SceneTree

const EnemyScript := preload("res://scripts/battle/enemy.gd")
const TowerStatsScript := preload("res://scripts/core/tower_stats.gd")
const MOUSE_FAST_SHEET_PATH := "res://assets/generated/enemies/mouse_fast_sheet.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var enemy: Node2D = EnemyScript.new()
	root.add_child(enemy)
	enemy.configure(TowerStatsScript.get_enemy("mouse_fast"), [Vector2(24, 360), Vector2(226, 360)])
	await process_frame
	await physics_frame

	var sprite: Sprite2D = _enemy_sprite(enemy)
	_assert_true(sprite != null, "mouse_fast should expose an animated Sprite2D")
	if sprite != null:
		_assert_true(sprite.texture != null, "mouse_fast sprite should have a texture")
		if sprite.texture != null:
			_assert_true(sprite.texture.resource_path == MOUSE_FAST_SHEET_PATH, "mouse_fast should use %s" % MOUSE_FAST_SHEET_PATH)
		_assert_true(sprite.region_enabled, "mouse_fast should use sprite-sheet regions")
		var visited_frames: Dictionary = {}
		for i: int in range(12):
			enemy.advance_along_path(0.06)
			await process_frame
			visited_frames[str(sprite.region_rect.position)] = true
		_assert_true(visited_frames.size() >= 2, "mouse_fast should cycle through running frames while moving")

	enemy.queue_free()
	_finish()


func _enemy_sprite(enemy: Node) -> Sprite2D:
	if enemy == null:
		return null
	var visual_root: Node = _find_by_name(enemy, "AnimatedEnemyVisual")
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
		print("MOUSE FAST ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("MOUSE FAST ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
