extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	_assert_battle_hud_uses_image2_assets(battle)

	var slot_layer: Node = battle.get_node_or_null("World/BuildSlots")
	_assert_true(slot_layer != null, "battle should expose build slots")
	if slot_layer == null:
		_finish()
		return

	var slots: Array[Node] = slot_layer.get_children()
	_assert_true(not slots.is_empty(), "battle should create at least one build slot")
	if slots.is_empty():
		_finish()
		return

	var slot: Node2D = slots[0] as Node2D
	var before_towers: int = int(battle.towers.size())
	var before_coins: int = int(battle.coins)
	var build_button: Button = _find_by_name(battle, "BuildSlot1Button") as Button
	_assert_true(build_button != null, "battle should expose a visible build button for the first slot")
	if build_button != null:
		var button_center: Vector2 = build_button.global_position + build_button.size * 0.5
		_assert_true(button_center.distance_to(slot.global_position) <= 1.0, "build button should sit on top of the slot it controls")
		build_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	await process_frame

	_assert_true(int(battle.towers.size()) == before_towers + 1, "pressing a visible build slot button should build a tower")
	_assert_true(int(battle.coins) < before_coins, "building from a visible build slot button should spend fish")

	if slots.size() >= 2:
		var second_slot: Node2D = slots[1] as Node2D
		var second_before_towers: int = int(battle.towers.size())
		var built_from_map_click: bool = bool(battle.call("_try_build_at_screen_position", second_slot.global_position))
		_assert_true(built_from_map_click, "map coordinate build fallback should accept clicks on empty slots")
		_assert_true(int(battle.towers.size()) == second_before_towers + 1, "map coordinate build fallback should create a tower")

	battle.queue_free()
	_finish()


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _assert_battle_hud_uses_image2_assets(battle: Node) -> void:
	_assert_texture_node(
		battle,
		"BattleHudTopFrame",
		"res://assets/generated/ui/battle_hud_top_bar.png",
		"battle should use an Image2 top HUD frame"
	)
	_assert_texture_node(
		battle,
		"BattleHudBottomFrame",
		"res://assets/generated/ui/battle_hud_bottom_dock.png",
		"battle should use an Image2 bottom build dock"
	)
	_assert_texture_node(
		battle,
		"BattlePauseFrame",
		"res://assets/generated/ui/battle_pause_button.png",
		"battle should use an Image2 pause button frame"
	)
	_assert_texture_node(
		battle,
		"BuildSlot1Visual",
		"res://assets/generated/ui/battle_build_slot_marker.png",
		"build slot visuals should use Image2 markers"
	)
	_assert_true(_find_by_name(battle, "BattleTopBar") == null, "battle should not render the old code-drawn top panel")
	_assert_true(_find_by_name(battle, "BuildPanel") == null, "battle should not render the old code-drawn build panel")


func _assert_texture_node(battle: Node, node_name: String, expected_path: String, message: String) -> void:
	var node: Node = _find_by_name(battle, node_name)
	_assert_true(node is TextureRect, message)
	if not node is TextureRect:
		return
	var texture_rect: TextureRect = node as TextureRect
	_assert_true(texture_rect.texture != null, "%s should have a texture" % node_name)
	if texture_rect.texture == null:
		return
	_assert_true(texture_rect.texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])


func _finish() -> void:
	if _failures.is_empty():
		print("BUILD INPUT TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BUILD INPUT TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
