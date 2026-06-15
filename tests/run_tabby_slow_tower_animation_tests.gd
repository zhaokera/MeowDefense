extends SceneTree

const EnemyScript := preload("res://scripts/battle/enemy.gd")
const TowerScript := preload("res://scripts/battle/tower.gd")
const TowerStatsScript := preload("res://scripts/core/tower_stats.gd")
const TABBY_SLOW_CAT_SHEET_PATH := "res://assets/generated/towers/tabby_slow_cat_sheet.png"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var tower: Node2D = TowerScript.new()
	root.add_child(tower)
	tower.configure("tabby_slow_cat", TowerStatsScript.get_tower("tabby_slow_cat"))
	tower.global_position = Vector2(240, 260)

	var enemy: Node2D = EnemyScript.new()
	root.add_child(enemy)
	enemy.configure(TowerStatsScript.get_enemy("mouse_basic"), [Vector2(280, 260), Vector2(440, 260)])
	enemy.global_position = Vector2(280, 260)
	await process_frame
	await physics_frame

	var sprite: Sprite2D = _tower_sprite(tower)
	_assert_true(sprite != null, "tabby slow cat tower should expose an animated Sprite2D")
	if sprite != null:
		_assert_true(sprite.texture != null, "tabby slow cat tower sprite should have a texture")
		if sprite.texture != null:
			_assert_true(sprite.texture.resource_path == TABBY_SLOW_CAT_SHEET_PATH, "tabby slow cat tower should use %s" % TABBY_SLOW_CAT_SHEET_PATH)
		_assert_true(sprite.region_enabled, "tabby slow cat tower should use sprite-sheet regions")
		var idle_rect: Rect2 = sprite.region_rect
		var target: Node2D = tower.tick(0.0, [enemy])
		await process_frame
		_assert_true(target == enemy, "tabby slow cat tower should fire at an enemy in range")
		_assert_true(sprite.region_rect.position != idle_rect.position, "tabby slow cat tower should switch to a firing animation frame")
		_assert_true(float(enemy.get("_slow_timer")) > 0.0, "tabby slow cat tower should apply a slow timer to its target")
		_assert_true(float(enemy.get("_slow_multiplier")) < 1.0, "tabby slow cat tower should reduce the target movement multiplier")

	_assert_manifest_entry("tabby_slow_cat_animation_design_reference", "res://assets/generated/towers/tabby_slow_cat_animation_design_reference.png")
	_assert_manifest_entry("tabby_slow_cat_sheet_source", "res://assets/generated/towers/tabby_slow_cat_sheet_source.png")

	tower.queue_free()
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
	var towers: Array = (parsed as Dictionary).get("towers", []) as Array
	for item: Variant in towers:
		if not (item is Dictionary):
			continue
		var entry: Dictionary = item as Dictionary
		if str(entry.get("id", "")) == id:
			_assert_true(str(entry.get("path", "")) == expected_path, "%s should point to %s" % [id, expected_path])
			return
	_failures.append("asset manifest should include %s" % id)


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
		print("TABBY SLOW TOWER ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("TABBY SLOW TOWER ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
