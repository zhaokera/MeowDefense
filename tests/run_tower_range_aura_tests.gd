extends SceneTree

const TowerScript := preload("res://scripts/battle/tower.gd")
const TowerStatsScript := preload("res://scripts/core/tower_stats.gd")
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const RANGE_DESIGN_PATH := "res://assets/generated/effects/tower_range_aura_design_reference.png"
const RANGE_ASSET_PATH := "res://assets/generated/effects/tower_range_aura.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var tower: Node2D = TowerScript.new()
	root.add_child(tower)
	tower.configure("orange_cat", TowerStatsScript.get_tower("orange_cat"))
	await process_frame

	_assert_range_aura(tower, "tower should render its attack range with an Image2 aura sprite")
	_assert_tower_script_no_code_draw()
	_assert_manifest_entry("tower_range_aura_design_reference", RANGE_DESIGN_PATH)
	_assert_manifest_entry("tower_range_aura", RANGE_ASSET_PATH)

	tower.queue_free()
	_finish()


func _assert_range_aura(tower: Node, message: String) -> void:
	var node: Node = _find_by_name(tower, "TowerRangeAura")
	if node == null:
		_failures.append(message)
		return
	if not node is Sprite2D:
		_failures.append("TowerRangeAura should be a Sprite2D")
		return
	var aura := node as Sprite2D
	_assert_true(aura.texture != null, "TowerRangeAura should have a texture")
	if aura.texture != null:
		_assert_true(aura.texture.resource_path == RANGE_ASSET_PATH, "TowerRangeAura should use %s" % RANGE_ASSET_PATH)
	_assert_true(aura.scale.x > 0.1 and aura.scale.y > 0.1, "TowerRangeAura should scale to the tower attack range")
	_assert_true(aura.z_index < 0, "TowerRangeAura should sit behind the tower art")
	_assert_true(aura.modulate.a > 0.0 and aura.modulate.a <= 1.0, "TowerRangeAura should be visible but not opaque UI chrome")


func _assert_tower_script_no_code_draw() -> void:
	var file := FileAccess.open("res://scripts/battle/tower.gd", FileAccess.READ)
	if file == null:
		_failures.append("tower script should be readable")
		return
	var source := file.get_as_text()
	_assert_true(not source.contains("draw_arc"), "tower attack range should not be a code-drawn arc")
	_assert_true(not source.contains("draw_circle"), "tower visuals should not fall back to code-drawn circles")
	_assert_true(not source.contains("draw_line"), "tower visuals should not use code-drawn line art")


func _assert_manifest_entry(id: String, expected_path: String) -> void:
	var manifest_file: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if manifest_file == null:
		_failures.append("asset manifest should be readable")
		return
	var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
	if not (parsed is Dictionary):
		_failures.append("asset manifest should parse as a dictionary")
		return
	var effect_items: Array = (parsed as Dictionary).get("effects", []) as Array
	for item: Variant in effect_items:
		if not (item is Dictionary):
			continue
		var entry: Dictionary = item as Dictionary
		if str(entry.get("id", "")) == id:
			_assert_true(str(entry.get("path", "")) == expected_path, "%s should point to %s" % [id, expected_path])
			return
	_failures.append("asset manifest should include %s" % id)


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
		print("TOWER RANGE AURA TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("TOWER RANGE AURA TESTS FAIL: %d" % _failures.size())
		quit(1)
