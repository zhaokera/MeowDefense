extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const WAVE_RUSH_BURST_PATH := "res://assets/generated/ui/battle_wave_rush_burst.png"
const WAVE_RUSH_SOURCE_PATH := "res://assets/generated/ui/battle_wave_rush_burst_source.png"
const WAVE_RUSH_REFERENCE_PATH := "res://assets/generated/ui/battle_wave_rush_feedback_design_reference.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	_assert_true(FileAccess.file_exists(WAVE_RUSH_REFERENCE_PATH), "wave rush should keep an Image2 full-screen battle reference")
	_assert_true(FileAccess.file_exists(WAVE_RUSH_SOURCE_PATH), "wave rush should keep the Image2 source burst")
	_assert_true(FileAccess.file_exists(WAVE_RUSH_BURST_PATH), "wave rush should use a project-bound transparent Image2 burst")
	_assert_manifest_entry("battle_wave_rush_feedback_design_reference", WAVE_RUSH_REFERENCE_PATH)
	_assert_manifest_entry("battle_wave_rush_burst_source", WAVE_RUSH_SOURCE_PATH)
	_assert_manifest_entry("battle_wave_rush_burst", WAVE_RUSH_BURST_PATH)

	var preview_frame: TextureRect = _assert_texture_node(
		battle,
		"WavePreviewFrame",
		"res://assets/generated/ui/battle_wave_preview_chip.png",
		"wave preview should remain an Image2 chip"
	) as TextureRect
	var rush_button: Button = _assert_button(battle, "RushNextWaveButton", "wave preview should expose a transparent rush-next-wave button")
	if rush_button != null and preview_frame != null:
		_assert_true(rush_button.text == "", "rush-next-wave control should not draw visible button text")
		_assert_true(rush_button.position == preview_frame.position, "rush-next-wave button should align to the Image2 wave chip")
		_assert_true(rush_button.size == preview_frame.size, "rush-next-wave button should cover the Image2 wave chip hit area")

	var before_elapsed: float = float(battle.elapsed)
	var before_enemies: int = int(battle.enemies.size())
	if rush_button != null:
		rush_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	await process_frame

	_assert_true(float(battle.elapsed) >= before_elapsed, "rushing a wave should not move time backward")
	_assert_true(int(battle.enemies.size()) > before_enemies, "rushing a wave should spawn the next enemy immediately")
	var preview_label: Label = _assert_label(battle, "WavePreviewLabel", "wave preview label should still exist after rush")
	if preview_label != null:
		_assert_true(preview_label.text.contains("第 1/3 波"), "after rushing, preview should show the active first wave")
	_assert_texture_node(
		battle,
		"BattleWaveRushFeedback1",
		WAVE_RUSH_BURST_PATH,
		"rushing a wave should show an Image2 wave-rush feedback burst"
	)
	var feedback_label: Label = _assert_label(battle, "BattleWaveRushFeedbackLabel", "wave-rush feedback should include dynamic text")
	if feedback_label != null:
		_assert_true(feedback_label.text.contains("提前开波"), "wave-rush feedback should explain the accelerated wave")

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
		print("BATTLE WAVE RUSH TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE WAVE RUSH TESTS FAIL: %d" % _failures.size())
		quit(1)
