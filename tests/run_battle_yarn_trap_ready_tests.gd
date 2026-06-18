extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const READY_BURST_PATH := "res://assets/generated/ui/battle_yarn_trap_ready_burst.png"

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

	_assert_true(battle.enemies.is_empty(), "test setup should start before the first enemy appears")
	var trap_button: Button = _assert_button(battle, "UseYarnTrapButton", "battle should expose yarn trap button")
	if trap_button != null:
		trap_button.emit_signal("pressed")
		for i: int in range(4):
			await process_frame

	_assert_true(_int_property(battle, "yarn_traps_available") == 1, "arming yarn trap before enemies spawn should not consume inventory immediately")
	_assert_texture_node(
		battle,
		"BattleYarnTrapReadyFeedback",
		READY_BURST_PATH,
		"armed yarn trap should show an Image2 ready feedback burst"
	)
	var ready_label: Label = _assert_label(battle, "BattleYarnTrapReadyFeedbackLabel", "ready feedback should explain the armed state")
	if ready_label != null:
		_assert_true(ready_label.text.contains("待机") or ready_label.text.contains("等"), "ready feedback should tell the player to wait for enemies")
	var icon: TextureRect = _assert_texture_node(
		battle,
		"YarnTrapReadyHudGlow",
		READY_BURST_PATH,
		"armed yarn trap should leave an Image2 glow on the HUD item"
	) as TextureRect
	if icon != null:
		_assert_true(icon.visible, "armed HUD glow should be visible while waiting")

	battle.simulate_step(0.6)
	await process_frame

	_assert_true(not battle.enemies.is_empty(), "test level should spawn an enemy")
	_assert_true(_int_property(battle, "yarn_traps_available") == 0, "armed yarn trap should consume inventory when it auto-fires")
	_assert_texture_node(
		battle,
		"YarnTrapFieldEffect1",
		"res://assets/generated/ui/yarn_trap_field_effect.png",
		"armed yarn trap should deploy the Image2 battlefield effect"
	)
	_assert_missing(battle, "YarnTrapReadyHudGlow", "armed HUD glow should clear after auto-fire")

	_assert_manifest_entry("battle_yarn_trap_ready_burst", READY_BURST_PATH)

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


func _assert_missing(root_node: Node, node_name: String, message: String) -> void:
	if _find_by_name(root_node, node_name) != null:
		_failures.append(message)


func _assert_manifest_entry(id: String, expected_path: String) -> void:
	var manifest_text: String = FileAccess.get_file_as_string("res://assets/generated/assets_manifest.json")
	if manifest_text == "":
		_failures.append("asset manifest should be readable")
		return
	var parsed: Variant = JSON.parse_string(manifest_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		_failures.append("asset manifest should parse as a dictionary")
		return
	var ui_items: Array = (parsed as Dictionary).get("ui", []) as Array
	for entry: Variant in ui_items:
		if typeof(entry) == TYPE_DICTIONARY and str(entry.get("id", "")) == id:
			_assert_true(str(entry.get("path", "")) == expected_path, "manifest entry %s should point to %s" % [id, expected_path])
			return
	_failures.append("assets manifest should include %s" % id)


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
		print("BATTLE YARN TRAP READY TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE YARN TRAP READY TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
