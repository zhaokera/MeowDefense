extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const TowerStatsScript := preload("res://scripts/core/tower_stats.gd")
const RANGE_ASSET_PATH := "res://assets/generated/effects/tower_range_aura.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	await process_frame
	await physics_frame

	var first_preview: Sprite2D = _assert_preview(battle, "BuildSlot1RangePreview", "orange_cat")
	var second_preview: Sprite2D = _assert_preview(battle, "BuildSlot2RangePreview", "orange_cat")
	var orange_scale: float = first_preview.scale.x if first_preview != null else 0.0

	var tabby_button: Button = _find_by_name(battle, "SelectTowerTabbySlowCatButton") as Button
	_assert_true(tabby_button != null, "tabby tower card should expose a transparent hit area")
	if tabby_button != null:
		tabby_button.emit_signal("pressed")
		await create_timer(0.25).timeout

	first_preview = _find_by_name(battle, "BuildSlot1RangePreview") as Sprite2D
	second_preview = _find_by_name(battle, "BuildSlot2RangePreview") as Sprite2D
	_assert_preview_scale(first_preview, "tabby_slow_cat", "first build slot range preview should resize for selected tabby tower")
	_assert_preview_scale(second_preview, "tabby_slow_cat", "second build slot range preview should resize for selected tabby tower")
	if first_preview != null:
		_assert_true(first_preview.scale.x < orange_scale, "tabby range preview should be smaller than orange range preview")

	var build_button: Button = _find_by_name(battle, "BuildSlot1Button") as Button
	_assert_true(build_button != null, "first build slot should expose a transparent hit area")
	if build_button != null:
		build_button.emit_signal("pressed")
		await process_frame
		await physics_frame
		await process_frame

	first_preview = _find_by_name(battle, "BuildSlot1RangePreview") as Sprite2D
	second_preview = _find_by_name(battle, "BuildSlot2RangePreview") as Sprite2D
	_assert_true(first_preview != null and not first_preview.visible, "occupied build slots should hide the range preview")
	_assert_true(second_preview != null and second_preview.visible, "empty build slots should keep showing the selected tower range preview")

	battle.queue_free()
	_finish()


func _assert_preview(battle: Node, node_name: String, tower_id: String) -> Sprite2D:
	var preview: Sprite2D = _find_by_name(battle, node_name) as Sprite2D
	_assert_true(preview != null, "%s should exist for empty build slots" % node_name)
	if preview == null:
		return null
	_assert_true(preview.texture != null, "%s should use an Image2 texture" % node_name)
	if preview.texture != null:
		_assert_true(preview.texture.resource_path == RANGE_ASSET_PATH, "%s should use %s" % [node_name, RANGE_ASSET_PATH])
	_assert_true(preview.visible, "%s should be visible while its slot is empty" % node_name)
	_assert_true(preview.modulate.a > 0.0 and preview.modulate.a < 1.0, "%s should be translucent gameplay guidance" % node_name)
	_assert_true(preview.z_index < 4, "%s should sit behind the build marker" % node_name)
	_assert_preview_scale(preview, tower_id, "%s should match the selected tower range" % node_name)
	return preview


func _assert_preview_scale(preview: Sprite2D, tower_id: String, message: String) -> void:
	if preview == null or preview.texture == null:
		_failures.append(message)
		return
	var stats: Dictionary = TowerStatsScript.get_tower(tower_id)
	var expected: float = float(stats.get("range", 160.0)) * 2.0 / max(1.0, preview.texture.get_size().x)
	_assert_true(abs(preview.scale.x - expected) <= 0.05, "%s: expected x scale %.3f, got %.3f" % [message, expected, preview.scale.x])
	_assert_true(abs(preview.scale.y - expected) <= 0.05, "%s: expected y scale %.3f, got %.3f" % [message, expected, preview.scale.y])


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
		print("BUILD SLOT RANGE PREVIEW TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BUILD SLOT RANGE PREVIEW TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
