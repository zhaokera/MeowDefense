extends SceneTree

const EnemyScript := preload("res://scripts/battle/enemy.gd")
const TowerStatsScript := preload("res://scripts/core/tower_stats.gd")
const HAMSTER_RUNNER_SHEET_PATH := "res://assets/generated/enemies/hamster_runner_sheet.png"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var enemy: Node2D = EnemyScript.new()
	root.add_child(enemy)
	enemy.configure(TowerStatsScript.get_enemy("hamster_runner"), [Vector2(24, 360), Vector2(246, 360)])
	await process_frame
	await physics_frame

	var sprite: Sprite2D = _enemy_sprite(enemy)
	_assert_true(sprite != null, "hamster_runner should expose an animated Sprite2D")
	if sprite != null:
		_assert_true(sprite.texture != null, "hamster_runner sprite should have a texture")
		if sprite.texture != null:
			_assert_true(sprite.texture.resource_path == HAMSTER_RUNNER_SHEET_PATH, "hamster_runner should use %s" % HAMSTER_RUNNER_SHEET_PATH)
		_assert_true(sprite.region_enabled, "hamster_runner should use sprite-sheet regions")
		var visited_frames: Dictionary = {}
		for i: int in range(10):
			enemy.advance_along_path(0.04)
			await process_frame
			visited_frames[str(sprite.region_rect.position)] = true
		_assert_true(visited_frames.size() >= 2, "hamster_runner should cycle through sprint frames while moving")

		enemy.take_damage(1.0)
		await process_frame
		_assert_true(int(enemy.get("_sprite_frame")) == 1, "hamster_runner should switch to the hit frame when damaged")
		enemy.take_damage(999.0)
		await process_frame
		_assert_true(int(enemy.get("_sprite_frame")) == 3, "hamster_runner should switch to the defeated frame when defeated")

	_assert_manifest_entry("hamster_runner_animation_design_reference", "res://assets/generated/enemies/hamster_runner_animation_design_reference.png")
	_assert_manifest_entry("hamster_runner_sheet_source", "res://assets/generated/enemies/hamster_runner_sheet_source.png")

	enemy.queue_free()
	_finish()


func _assert_manifest_entry(id: String, expected_path: String) -> void:
	var manifest_file: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if manifest_file == null:
		_failures.append("asset manifest should be readable")
		return
	var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
	if not (parsed is Dictionary):
		_failures.append("asset manifest should parse as a dictionary")
		return
	var enemies: Array = (parsed as Dictionary).get("enemies", []) as Array
	for item: Variant in enemies:
		if not (item is Dictionary):
			continue
		var entry: Dictionary = item as Dictionary
		if str(entry.get("id", "")) == id:
			_assert_true(str(entry.get("path", "")) == expected_path, "%s should point to %s" % [id, expected_path])
			return
	_failures.append("asset manifest should include %s" % id)


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
		print("HAMSTER RUNNER ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("HAMSTER RUNNER ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
