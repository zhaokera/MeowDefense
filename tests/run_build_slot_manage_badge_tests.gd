extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const MANAGE_BADGE_PATH := "res://assets/generated/ui/album_paw_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var badge: TextureRect = _assert_manage_badge(battle, false)
	var base_scale: Vector2 = badge.scale if badge != null else Vector2.ONE
	var build_button: Button = _find_by_name(battle, "BuildSlot1Button") as Button
	_assert_true(build_button != null, "first build slot should expose a transparent hit area")
	if build_button == null:
		_finish(battle)
		return

	build_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	badge = _assert_manage_badge(battle, true)

	build_button.emit_signal("pressed")
	await process_frame
	_assert_true(_find_by_name(battle, "TowerActionOverlay") != null, "pressing an occupied slot should open tower management")
	badge = _find_by_name(battle, "BuildSlot1ManageBadge") as TextureRect
	if badge != null:
		_assert_true(bool(badge.get_meta("image2_slot_manage_feedback", false)), "occupied slot manage badge should mark local Image2 feedback")
		_assert_true(badge.scale.x > base_scale.x and badge.scale.y > base_scale.y, "occupied slot manage badge should pop larger after opening management")

	var sell_button: Button = _find_by_name(battle, "SellTowerButton") as Button
	_assert_true(sell_button != null, "tower management should expose sell")
	if sell_button != null:
		sell_button.emit_signal("pressed")
		await process_frame
	badge = _assert_manage_badge(battle, false)
	_assert_true(int(battle.towers.size()) == 0, "selling should remove the tower during manage badge flow")

	_finish(battle)


func _assert_manage_badge(battle: Node, expected_visible: bool) -> TextureRect:
	var badge: TextureRect = _find_by_name(battle, "BuildSlot1ManageBadge") as TextureRect
	_assert_true(badge != null, "build slot should expose an Image2 manage badge node")
	if badge == null:
		return null
	_assert_true(badge.texture != null, "build slot manage badge should have a texture")
	if badge.texture != null:
		_assert_true(badge.texture.resource_path == MANAGE_BADGE_PATH, "build slot manage badge should use %s" % MANAGE_BADGE_PATH)
	_assert_true(badge.visible == expected_visible, "build slot manage badge visibility should match occupied state")
	_assert_true(badge.size.x <= 58.0 and badge.size.y <= 58.0, "build slot manage badge should stay slot-sized")
	_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "build slot manage badge should not block the transparent hit area")
	return badge


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _finish(battle: Node) -> void:
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	if _failures.is_empty():
		print("BUILD SLOT MANAGE BADGE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BUILD SLOT MANAGE BADGE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
