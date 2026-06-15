extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	battle.set("yarn_traps_available", 1)
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	_assert_texture_node(
		battle,
		"YarnTrapHudIcon",
		"res://assets/generated/ui/yarn_trap_item_icon.png",
		"battle should expose the yarn trap item with an Image2 icon"
	)
	var count_label: Label = _assert_label(battle, "YarnTrapCountLabel", "battle should show yarn trap count")
	if count_label != null:
		_assert_true(count_label.text.contains("1"), "battle yarn trap count should start from inventory")
	var trap_button: Button = _assert_button(battle, "UseYarnTrapButton", "battle should expose a yarn trap use button")

	battle.simulate_step(0.6)
	await process_frame
	_assert_true(not battle.enemies.is_empty(), "test level should spawn an enemy before using the trap")
	var enemy: Node2D = battle.enemies[0] as Node2D if not battle.enemies.is_empty() else null
	if enemy != null:
		_assert_true(float(enemy.get("_slow_timer")) <= 0.0, "enemy should start unslowed")

	if trap_button != null:
		trap_button.emit_signal("pressed")
		await process_frame

	_assert_true(_int_property(battle, "yarn_traps_available") == 0, "using yarn trap should consume one inventory item")
	if count_label != null:
		_assert_true(count_label.text.contains("0"), "battle yarn trap count should update after use")
	if enemy != null:
		_assert_true(float(enemy.get("_slow_timer")) > 0.0, "yarn trap should slow an active enemy")
	_assert_texture_node(
		battle,
		"YarnTrapFieldEffect1",
		"res://assets/generated/ui/yarn_trap_field_effect.png",
		"deployed yarn trap should use an Image2 battlefield effect"
	)

	battle.queue_free()
	_finish()


func _int_property(instance: Node, property_name: String) -> int:
	var raw: Variant = instance.get(property_name)
	if raw == null:
		return 0
	return int(raw)


func _assert_texture_node(root_node: Node, node_name: String, expected_path: String, message: String) -> Node:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if not node is TextureRect and not node is Sprite2D:
		_failures.append("%s should be a TextureRect or Sprite2D" % node_name)
		return null
	var texture: Texture2D = null
	if node is TextureRect:
		texture = (node as TextureRect).texture
	elif node is Sprite2D:
		texture = (node as Sprite2D).texture
	_assert_true(texture != null, "%s should have a texture" % node_name)
	if texture != null:
		_assert_true(texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])
	return node


func _assert_label(root_node: Node, node_name: String, message: String) -> Label:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Label:
		return node as Label
	_failures.append("%s should be a Label" % node_name)
	return null


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
	return null


func _assert_exists(root_node: Node, node_name: String, message: String) -> Node:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
	return node


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
		print("BATTLE YARN TRAP TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE YARN TRAP TESTS FAIL: %d" % _failures.size())
		quit(1)
