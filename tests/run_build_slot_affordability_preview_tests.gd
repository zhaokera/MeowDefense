extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

const SHORTAGE_STAMP_PATH := "res://assets/generated/ui/battle_tower_card_insufficient_fish_stamp.png"
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

	battle.set("coins", 65)
	battle.call("_update_hud")
	var tabby_button: Button = _find_by_name(battle, "SelectTowerTabbySlowCatButton") as Button
	_assert_true(tabby_button != null, "tabby tower card should expose a transparent hit area")
	if tabby_button != null:
		tabby_button.emit_signal("pressed")
	await create_timer(0.25).timeout

	_assert_slot_shortage_state(battle, true)

	battle.set("coins", 75)
	battle.call("_update_hud")
	await process_frame

	_assert_slot_shortage_state(battle, false)

	battle.queue_free()
	_finish()


func _assert_slot_shortage_state(battle: Node, expected_shortage: bool) -> void:
	var stamp: Sprite2D = _find_by_name(battle, "BuildSlot1AffordabilityStamp") as Sprite2D
	_assert_true(stamp != null, "empty build slots should expose an Image2 affordability stamp")
	if stamp != null:
		_assert_true(stamp.texture != null, "build slot affordability stamp should have a texture")
		if stamp.texture != null:
			_assert_true(stamp.texture.resource_path == SHORTAGE_STAMP_PATH, "build slot affordability stamp should use %s" % SHORTAGE_STAMP_PATH)
			var rendered_size: Vector2 = stamp.texture.get_size() * stamp.scale
			_assert_true(rendered_size.x <= 72.0 and rendered_size.y <= 72.0, "build slot affordability stamp should be scaled to a slot-sized badge")
		_assert_true(stamp.visible == expected_shortage, "build slot affordability stamp visibility should match selected tower affordability")
		_assert_true(stamp.z_index > -1 and stamp.z_index < 4, "build slot affordability stamp should sit above the ghost and below the HUD marker")

	var ghost: Sprite2D = _find_by_name(battle, "BuildSlot1TowerGhost") as Sprite2D
	_assert_true(ghost != null, "build slot tower ghost should exist")
	if ghost != null:
		_assert_true(ghost.texture != null, "build slot tower ghost should have a texture")
		if ghost.texture != null:
			_assert_true(ghost.texture.resource_path == TABBY_TOWER_PATH, "selected tabby tower ghost should stay visible while unaffordable")
		_assert_true(ghost.visible, "empty build slot tower ghost should stay visible while showing affordability")
		if expected_shortage:
			_assert_true(ghost.modulate.r < 0.85 and ghost.modulate.g < 0.85 and ghost.modulate.b < 0.85, "unaffordable tower ghost should be visibly dimmed")
		else:
			_assert_true(ghost.modulate.r > 0.95 and ghost.modulate.g > 0.95 and ghost.modulate.b > 0.95, "affordable tower ghost should restore normal color")


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
		print("BUILD SLOT AFFORDABILITY PREVIEW TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BUILD SLOT AFFORDABILITY PREVIEW TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
