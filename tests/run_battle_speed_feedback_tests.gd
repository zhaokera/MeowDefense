extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const SPEED_FEEDBACK_REFERENCE_PATH := "res://assets/generated/ui/battle_speed_feedback_design_reference.png"
const SPEED_FEEDBACK_SOURCE_PATH := "res://assets/generated/ui/battle_speed_feedback_burst_source.png"
const SPEED_FEEDBACK_BURST_PATH := "res://assets/generated/ui/battle_speed_feedback_burst.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	_assert_true(FileAccess.file_exists(SPEED_FEEDBACK_REFERENCE_PATH), "speed toggle should keep an Image2 full-screen battle reference")
	_assert_true(FileAccess.file_exists(SPEED_FEEDBACK_SOURCE_PATH), "speed toggle should keep the Image2 source burst")
	_assert_true(FileAccess.file_exists(SPEED_FEEDBACK_BURST_PATH), "speed toggle should use a project-bound transparent Image2 burst")
	_assert_manifest_entry("battle_speed_feedback_design_reference", SPEED_FEEDBACK_REFERENCE_PATH)
	_assert_manifest_entry("battle_speed_feedback_burst_source", SPEED_FEEDBACK_SOURCE_PATH)
	_assert_manifest_entry("battle_speed_feedback_burst", SPEED_FEEDBACK_BURST_PATH)

	var speed_frame: TextureRect = _assert_texture_node(
		battle,
		"SpeedControlFrame",
		"res://assets/generated/ui/battle_speed_button.png",
		"speed control should remain an Image2 button asset"
	) as TextureRect
	var speed_button: Button = _assert_button(battle, "SpeedToggleButton", "battle HUD should expose speed toggle input")
	if speed_button != null:
		speed_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	await process_frame

	_assert_true(float(battle.get("_battle_speed_multiplier")) == 2.0, "pressing speed should switch to 2x")
	var feedback: TextureRect = _assert_texture_node(
		battle,
		"BattleSpeedFeedback1",
		SPEED_FEEDBACK_BURST_PATH,
		"pressing speed should show an Image2 speed feedback burst"
	) as TextureRect
	var label: Label = _assert_label(battle, "BattleSpeedFeedbackLabel", "speed feedback should include dynamic speed text")
	if label != null:
		_assert_true(label.text.contains("2x"), "speed feedback should show the active 2x state")
	if speed_frame != null:
		_assert_true(bool(speed_frame.get_meta("image2_speed_feedback", false)), "speed button frame should mark active Image2 speed feedback")
	if feedback != null:
		_assert_true(feedback.z_index > 0, "speed feedback should render above the battle HUD")

	battle.queue_free()
	_finish()


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


func _finish() -> void:
	if _failures.is_empty():
		print("BATTLE SPEED FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE SPEED FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
