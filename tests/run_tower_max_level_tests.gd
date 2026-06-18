extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const MAX_LEVEL_STAMP_PATH := "res://assets/generated/ui/tower_max_level_stamp.png"
const MAX_LEVEL_BURST_PATH := "res://assets/generated/ui/tower_max_level_burst.png"
const MAX_LEVEL_REFERENCE_PATH := "res://assets/generated/ui/tower_max_level_feedback_design_reference.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	_assert_true(FileAccess.file_exists(MAX_LEVEL_REFERENCE_PATH), "tower max-level state should keep an Image2 design reference")
	_assert_true(FileAccess.file_exists(MAX_LEVEL_STAMP_PATH), "tower max-level state should use a project-bound Image2 stamp")
	_assert_true(FileAccess.file_exists(MAX_LEVEL_BURST_PATH), "tower max-level feedback should use a project-bound Image2 burst")
	_assert_manifest_entry("tower_max_level_feedback_design_reference", MAX_LEVEL_REFERENCE_PATH)
	_assert_manifest_entry("tower_max_level_stamp", MAX_LEVEL_STAMP_PATH)
	_assert_manifest_entry("tower_max_level_burst", MAX_LEVEL_BURST_PATH)

	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "battle should expose first build slot")
	if build_button == null:
		_finish(battle)
		return
	build_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	_assert_true(int(battle.towers.size()) == 1, "setup should build one tower")
	var tower: Node2D = battle.towers[0] as Node2D if int(battle.towers.size()) > 0 else null
	if tower == null:
		_finish(battle)
		return
	battle.set("coins", 500)

	build_button = _assert_button(battle, "BuildSlot1Button", "occupied tower slot should remain tappable")
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame

	var upgrade_button: Button = _assert_button(battle, "UpgradeTowerButton", "tower action overlay should expose upgrade")
	if upgrade_button == null:
		_finish(battle)
		return
	upgrade_button.emit_signal("pressed")
	await process_frame
	upgrade_button.emit_signal("pressed")
	await process_frame

	_assert_true(int(tower.get("level")) == 3, "two upgrades should bring the tower to max level 3")
	_assert_texture_node(
		battle,
		"TowerMaxLevelStamp",
		MAX_LEVEL_STAMP_PATH,
		"max-level tower action overlay should show an Image2 max stamp"
	)
	var max_label: Label = _assert_label(battle, "TowerMaxLevelLabel", "max-level stamp should include dynamic max-level text")
	if max_label != null:
		_assert_true(max_label.text.contains("满级"), "max-level label should read 满级")
	var coins_at_max: int = int(battle.get("coins"))

	upgrade_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	_assert_true(int(tower.get("level")) == 3, "pressing upgrade at max level should not increase tower level")
	_assert_true(int(battle.get("coins")) == coins_at_max, "pressing upgrade at max level should not spend fish")
	_assert_texture_node(
		battle,
		"TowerMaxLevelFeedback",
		MAX_LEVEL_BURST_PATH,
		"pressing upgrade at max level should show an Image2 max-level burst"
	)
	var feedback_label: Label = _assert_label(battle, "TowerMaxLevelFeedbackLabel", "max-level feedback should include dynamic text")
	if feedback_label != null:
		_assert_true(feedback_label.text.contains("满级"), "max-level feedback should explain the tower is maxed")

	_finish(battle)


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


func _finish(battle: Node) -> void:
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	if _failures.is_empty():
		print("TOWER MAX LEVEL TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("TOWER MAX LEVEL TESTS FAIL: %d" % _failures.size())
		quit(1)
