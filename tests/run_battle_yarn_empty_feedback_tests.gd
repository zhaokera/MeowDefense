extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const EMPTY_BURST_PATH := "res://assets/generated/ui/battle_yarn_trap_empty_burst.png"
const EMPTY_BURST_SOURCE_PATH := "res://assets/generated/ui/battle_yarn_trap_empty_burst_source.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	battle.set("yarn_traps_available", 0)
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var trap_button: Button = _assert_button(battle, "UseYarnTrapButton", "battle should expose a yarn trap use button even when empty")
	if trap_button != null:
		trap_button.emit_signal("pressed")
		for i: int in range(3):
			await process_frame

	_assert_true(_int_property(battle, "yarn_traps_available") == 0, "empty yarn trap feedback should not change inventory")
	_assert_missing(battle, "YarnTrapFieldEffect1", "empty yarn trap feedback should not place a trap field")
	_assert_texture_node(
		battle,
		"BattleYarnTrapEmptyFeedback",
		EMPTY_BURST_PATH,
		"empty yarn trap press should show an Image2 empty-trap feedback burst"
	)
	var label: Label = _assert_label(battle, "BattleYarnTrapEmptyFeedbackLabel", "empty yarn trap feedback should explain the next step")
	if label != null:
		_assert_true(label.text.contains("毛线陷阱") and label.text.contains("商店"), "empty yarn trap feedback should mention yarn traps and the shop")
	var count_label: Label = _assert_label(battle, "YarnTrapCountLabel", "battle should keep showing yarn trap count")
	if count_label != null:
		_assert_true(count_label.text.contains("0"), "empty yarn trap count should remain zero")

	_assert_manifest_entry("battle_yarn_trap_empty_burst_source", EMPTY_BURST_SOURCE_PATH)
	_assert_manifest_entry("battle_yarn_trap_empty_burst", EMPTY_BURST_PATH)

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


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
	return null


func _assert_label(root_node: Node, node_name: String, message: String) -> Label:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Label:
		return node as Label
	_failures.append("%s should be a Label" % node_name)
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
		print("BATTLE YARN EMPTY FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE YARN EMPTY FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
