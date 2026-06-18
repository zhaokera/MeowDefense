extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const SHORTAGE_STAMP_PATH := "res://assets/generated/ui/battle_tower_card_insufficient_fish_stamp.png"

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

	var stamp: Sprite2D = _find_by_name(battle, "BuildSlot1AffordabilityStamp") as Sprite2D
	_assert_stamp_ready(stamp)
	var base_scale: Vector2 = stamp.scale if stamp != null else Vector2.ONE
	var before_towers: int = int(battle.towers.size())
	var before_coins: int = int(battle.get("coins"))

	var build_button: Button = _find_by_name(battle, "BuildSlot1Button") as Button
	_assert_true(build_button != null, "first build slot should expose a transparent hit area")
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame

	_assert_true(int(battle.towers.size()) == before_towers, "unaffordable build slot tap should not create a tower")
	_assert_true(int(battle.get("coins")) == before_coins, "unaffordable build slot tap should not spend fish")
	var resource_feedback: TextureRect = _find_by_name(battle, "BattleResourceFeedback") as TextureRect
	_assert_true(resource_feedback != null, "unaffordable build slot tap should still show global Image2 resource feedback")
	stamp = _find_by_name(battle, "BuildSlot1AffordabilityStamp") as Sprite2D
	if stamp != null:
		_assert_true(bool(stamp.get_meta("image2_slot_affordability_feedback", false)), "build slot affordability stamp should mark local Image2 feedback")
		_assert_true(stamp.scale.x > base_scale.x and stamp.scale.y > base_scale.y, "build slot affordability stamp should pop larger immediately after an unaffordable tap")

	battle.queue_free()
	_finish()


func _assert_stamp_ready(stamp: Sprite2D) -> void:
	_assert_true(stamp != null, "build slot affordability stamp should exist before tap")
	if stamp == null:
		return
	_assert_true(stamp.visible, "build slot affordability stamp should be visible before an unaffordable tap")
	_assert_true(stamp.texture != null, "build slot affordability stamp should have a texture")
	if stamp.texture != null:
		_assert_true(stamp.texture.resource_path == SHORTAGE_STAMP_PATH, "build slot affordability stamp should use %s" % SHORTAGE_STAMP_PATH)


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
		print("BUILD SLOT AFFORDABILITY FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BUILD SLOT AFFORDABILITY FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
