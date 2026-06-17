extends SceneTree

const EnemyScript := preload("res://scripts/battle/enemy.gd")
const FALLBACK_ENEMY_PATH := "res://assets/generated/enemies/mouse_basic_sheet.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var enemy: Node2D = EnemyScript.new()
	root.add_child(enemy)
	enemy.configure({
		"id": "unknown_mouse",
		"name": "测试小鼠",
		"max_hp": 12,
		"speed": 70.0,
		"reward": 1,
		"damage": 1,
		"texture": "res://assets/generated/enemies/missing_enemy_texture.png"
	}, [Vector2(24, 360), Vector2(226, 360)])
	await process_frame
	await physics_frame

	var sprite: Sprite2D = _enemy_sprite(enemy)
	_assert_true(sprite != null, "enemy should expose a Sprite2D even when configured texture is missing")
	if sprite != null:
		_assert_true(sprite.texture != null, "enemy fallback sprite should have a texture")
		if sprite.texture != null:
			_assert_true(sprite.texture.resource_path == FALLBACK_ENEMY_PATH, "enemy fallback should use %s" % FALLBACK_ENEMY_PATH)
		_assert_true(sprite.region_enabled, "enemy fallback should keep sprite-sheet regions")
		_assert_true(sprite.scale.x > 0.0 and sprite.scale.y > 0.0, "enemy fallback should keep readable scale")
	_assert_enemy_script_no_code_draw()

	enemy.queue_free()
	_finish()


func _enemy_sprite(enemy: Node) -> Sprite2D:
	var visual_root: Node = _find_by_name(enemy, "AnimatedEnemyVisual")
	if visual_root == null:
		return null
	return _find_first_sprite(visual_root)


func _assert_enemy_script_no_code_draw() -> void:
	var file := FileAccess.open("res://scripts/battle/enemy.gd", FileAccess.READ)
	if file == null:
		_failures.append("enemy script should be readable")
		return
	var source := file.get_as_text()
	_assert_true(not source.contains("draw_circle"), "enemy visuals should not fall back to code-drawn circles")
	_assert_true(not source.contains("draw_arc"), "enemy visuals should not fall back to code-drawn arcs")


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
		print("ENEMY FALLBACK ASSET TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ENEMY FALLBACK ASSET TESTS FAIL: %d" % _failures.size())
		quit(1)
