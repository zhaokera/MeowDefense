extends SceneTree

const EnemyScript := preload("res://scripts/battle/enemy.gd")
const TowerStatsScript := preload("res://scripts/core/tower_stats.gd")
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const HEALTH_DESIGN_PATH := "res://assets/generated/ui/enemy_health_bar_design_reference.png"
const HEALTH_UNDER_PATH := "res://assets/generated/ui/enemy_health_bar_under.png"
const HEALTH_FILL_PATH := "res://assets/generated/ui/enemy_health_bar_fill.png"
const HEALTH_DANGER_FILL_PATH := "res://assets/generated/ui/enemy_health_bar_danger_fill.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var enemy: Node2D = EnemyScript.new()
	root.add_child(enemy)
	enemy.configure(TowerStatsScript.get_enemy("mouse_basic"), [Vector2(24, 360), Vector2(226, 360)])
	await process_frame

	var bar: TextureProgressBar = _assert_health_bar(enemy, "enemy should render an Image2 texture progress health bar")
	var frame: TextureRect = _assert_health_frame(enemy, "enemy should render an Image2 health bar frame with badge and fish cap")
	if bar != null:
		_assert_true(bar.texture_under == null, "enemy health bar fill should not cover the Image2 badge frame as a progress under texture")
		_assert_true(bar.texture_progress != null, "enemy health bar should use an Image2 fill texture")
		if bar.texture_progress != null:
			_assert_true(bar.texture_progress.resource_path == HEALTH_FILL_PATH, "enemy health bar fill texture should use %s" % HEALTH_FILL_PATH)
		_assert_true(is_equal_approx(float(bar.value), 1.0), "enemy health bar should start full")
	if frame != null and bar != null:
		_assert_true(frame.texture != null, "enemy health bar frame should use an Image2 frame texture")
		if frame.texture != null:
			_assert_true(frame.texture.resource_path == HEALTH_UNDER_PATH, "enemy health bar frame should use %s" % HEALTH_UNDER_PATH)
		_assert_true(frame.size.x > bar.size.x, "enemy health bar frame should be wider than the fill so decorative caps remain visible")
		_assert_true(frame.size.y > bar.size.y, "enemy health bar frame should be taller than the fill so the fill sits inside the frame")
		_assert_true(frame.size.x >= 110.0, "enemy health bar frame should stay readable at battle scale")
		_assert_true(bar.size.x >= 68.0, "enemy health bar fill should stay readable at battle scale")

	enemy.take_damage(float(enemy.get("max_hp")) * 0.75)
	await process_frame
	if bar != null:
		_assert_true(float(bar.value) <= 0.26, "enemy health bar should shrink after damage")
		_assert_true(bar.texture_progress != null, "damaged enemy health bar should keep a progress texture")
		if bar.texture_progress != null:
			_assert_true(bar.texture_progress.resource_path == HEALTH_DANGER_FILL_PATH, "low enemy health should switch to the Image2 danger fill")
	_assert_no_code_drawn_health_rect(enemy)

	_assert_manifest_entry("enemy_health_bar_design_reference", HEALTH_DESIGN_PATH)
	_assert_manifest_entry("enemy_health_bar_under", HEALTH_UNDER_PATH)
	_assert_manifest_entry("enemy_health_bar_fill", HEALTH_FILL_PATH)
	_assert_manifest_entry("enemy_health_bar_danger_fill", HEALTH_DANGER_FILL_PATH)

	enemy.queue_free()
	_finish()


func _assert_health_bar(root_node: Node, message: String) -> TextureProgressBar:
	var node: Node = _find_by_name(root_node, "EnemyHealthBar")
	if node == null:
		_failures.append(message)
		return null
	if node is TextureProgressBar:
		return node as TextureProgressBar
	_failures.append("EnemyHealthBar should be a TextureProgressBar")
	return null


func _assert_health_frame(root_node: Node, message: String) -> TextureRect:
	var node: Node = _find_by_name(root_node, "EnemyHealthBarFrame")
	if node == null:
		_failures.append(message)
		return null
	if node is TextureRect:
		return node as TextureRect
	_failures.append("EnemyHealthBarFrame should be a TextureRect")
	return null


func _assert_no_code_drawn_health_rect(node: Node) -> void:
	if node is ColorRect:
		_failures.append("enemy health bar should not be a code-drawn ColorRect")
	for child: Node in node.get_children():
		_assert_no_code_drawn_health_rect(child)


func _assert_manifest_entry(id: String, expected_path: String) -> void:
	var manifest_file: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if manifest_file == null:
		_failures.append("asset manifest should be readable")
		return
	var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
	if not (parsed is Dictionary):
		_failures.append("asset manifest should parse as a dictionary")
		return
	var ui_items: Array = (parsed as Dictionary).get("ui", []) as Array
	for item: Variant in ui_items:
		if not (item is Dictionary):
			continue
		var entry: Dictionary = item as Dictionary
		if str(entry.get("id", "")) == id:
			_assert_true(str(entry.get("path", "")) == expected_path, "%s should point to %s" % [id, expected_path])
			return
	_failures.append("asset manifest should include %s" % id)


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
		print("ENEMY HEALTH BAR ASSET TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ENEMY HEALTH BAR ASSET TESTS FAIL: %d" % _failures.size())
		quit(1)
