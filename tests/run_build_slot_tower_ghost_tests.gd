extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

const ORANGE_TOWER_PATH := "res://assets/generated/towers/orange_cat_tower_sheet.png"
const TABBY_TOWER_PATH := "res://assets/generated/towers/tabby_slow_cat_sheet.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	await process_frame
	await physics_frame

	var first_ghost: Sprite2D = _assert_tower_ghost(battle, "BuildSlot1TowerGhost", ORANGE_TOWER_PATH)
	var second_ghost: Sprite2D = _assert_tower_ghost(battle, "BuildSlot2TowerGhost", ORANGE_TOWER_PATH)
	_assert_true(first_ghost != null and first_ghost.visible, "first empty slot tower ghost should start visible")
	_assert_true(second_ghost != null and second_ghost.visible, "second empty slot tower ghost should start visible")

	var tabby_button: Button = _find_by_name(battle, "SelectTowerTabbySlowCatButton") as Button
	_assert_true(tabby_button != null, "tabby tower card should expose a transparent hit area")
	if tabby_button != null:
		tabby_button.emit_signal("pressed")
		await create_timer(0.25).timeout

	first_ghost = _assert_tower_ghost(battle, "BuildSlot1TowerGhost", TABBY_TOWER_PATH)
	second_ghost = _assert_tower_ghost(battle, "BuildSlot2TowerGhost", TABBY_TOWER_PATH)

	var build_button: Button = _find_by_name(battle, "BuildSlot1Button") as Button
	_assert_true(build_button != null, "first build slot should expose a transparent hit area")
	if build_button != null:
		build_button.emit_signal("pressed")
		await process_frame
		await physics_frame
		await process_frame

	first_ghost = _find_by_name(battle, "BuildSlot1TowerGhost") as Sprite2D
	second_ghost = _find_by_name(battle, "BuildSlot2TowerGhost") as Sprite2D
	_assert_true(first_ghost != null and not first_ghost.visible, "occupied build slots should hide the tower ghost")
	_assert_true(second_ghost != null and second_ghost.visible, "empty build slots should keep showing the selected tower ghost")
	if second_ghost != null and second_ghost.texture != null:
		_assert_true(second_ghost.texture.resource_path == TABBY_TOWER_PATH, "remaining empty slots should keep the selected tabby tower ghost")

	battle.queue_free()
	_finish()


func _assert_tower_ghost(battle: Node, node_name: String, expected_path: String) -> Sprite2D:
	var ghost: Sprite2D = _find_by_name(battle, node_name) as Sprite2D
	_assert_true(ghost != null, "%s should exist for empty build slots" % node_name)
	if ghost == null:
		return null
	_assert_true(ghost.texture != null, "%s should use an Image2 tower texture" % node_name)
	if ghost.texture != null:
		_assert_true(ghost.texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])
		var texture_size: Vector2 = ghost.texture.get_size()
		var expected_region: Rect2 = Rect2(Vector2.ZERO, texture_size / 2.0)
		_assert_true(ghost.region_enabled, "%s should crop the first sprite-sheet frame" % node_name)
		_assert_true(ghost.region_rect == expected_region, "%s should show the idle frame from the tower sprite sheet" % node_name)
	_assert_true(ghost.modulate.a > 0.0 and ghost.modulate.a < 0.85, "%s should be a translucent build preview, not a real tower" % node_name)
	_assert_true(ghost.scale.x > 0.05 and ghost.scale.y > 0.05, "%s should be scaled to a readable slot preview" % node_name)
	_assert_true(ghost.z_index > -3 and ghost.z_index < 4, "%s should sit above the range aura and below the build marker" % node_name)
	return ghost


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
		print("BUILD SLOT TOWER GHOST TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BUILD SLOT TOWER GHOST TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
