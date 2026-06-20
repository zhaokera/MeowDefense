extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const CLOSE_REFERENCE_PATH := "res://assets/generated/ui/battle_wave_preview_close_feedback_design_reference.png"
const CLOSE_SOURCE_PATH := "res://assets/generated/ui/battle_wave_preview_close_feedback_badge_source.png"
const CLOSE_BADGE_PATH := "res://assets/generated/ui/battle_wave_preview_close_feedback_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_file_exists(CLOSE_REFERENCE_PATH, "wave preview close feedback should keep an Image2 battle reference")
	_assert_file_exists(CLOSE_SOURCE_PATH, "wave preview close feedback should keep its Image2-derived source asset")
	_assert_file_exists(CLOSE_BADGE_PATH, "wave preview close feedback should use a transparent runtime badge")
	_assert_manifest_entry("battle_wave_preview_close_feedback_design_reference", CLOSE_REFERENCE_PATH)
	_assert_manifest_entry("battle_wave_preview_close_feedback_badge_source", CLOSE_SOURCE_PATH)
	_assert_manifest_entry("battle_wave_preview_close_feedback_badge", CLOSE_BADGE_PATH)

	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	await process_frame
	await physics_frame

	var info_button: Button = _assert_button(battle, "WavePreviewInfoButton", "wave preview should expose an info hotspot")
	if info_button != null:
		info_button.emit_signal("pressed")
	await process_frame
	await process_frame
	_assert_exists(battle, "BattleWavePreviewDetailOverlay", "wave preview detail should open before close feedback is tested")

	var close_button: Button = _assert_button(battle, "CloseWavePreviewDetailButton", "wave preview detail should expose a close action")
	if close_button != null:
		close_button.emit_signal("pressed")
	await _wait_until_missing(battle, "BattleWavePreviewDetailOverlay")
	_assert_missing(battle, "BattleWavePreviewDetailOverlay", "closing wave preview detail should remove the overlay")

	var feedback: TextureRect = _assert_texture_node(
		battle,
		"WavePreviewCloseFeedback",
		CLOSE_BADGE_PATH,
		"closing wave preview detail should show an Image2 close feedback badge"
	)
	if feedback != null:
		_assert_true(bool(feedback.get_meta("image2_wave_preview_close_feedback", false)), "wave preview close feedback should mark Image2 metadata")
		_assert_true(feedback.mouse_filter == Control.MOUSE_FILTER_IGNORE, "wave preview close feedback should not block battle input")
	var label: Label = _assert_label(battle, "WavePreviewCloseFeedbackLabel", "wave preview close feedback should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("情报收起") or label.text.contains("继续布防"), "wave preview close feedback copy should explain that scouting is closed")
	var preview_button: Button = _assert_button(battle, "RushNextWaveButton", "wave preview rush hotspot should remain available after close feedback")
	if preview_button != null:
		_assert_true(not preview_button.disabled, "wave preview rush hotspot should remain enabled after close feedback")

	battle.queue_free()
	_finish()


func _assert_manifest_entry(entry_id: String, expected_path: String) -> void:
	if not FileAccess.file_exists(MANIFEST_PATH):
		_failures.append("assets manifest should exist")
		return
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		_failures.append("assets manifest should be readable")
		return
	var data: Variant = JSON.parse_string(file.get_as_text())
	if not data is Dictionary:
		_failures.append("assets manifest should be a JSON object")
		return
	var entries: Array = (data as Dictionary).get("ui", []) as Array
	for entry: Variant in entries:
		if entry is Dictionary and str(entry.get("id", "")) == entry_id:
			_assert_true(str(entry.get("path", "")) == expected_path, "%s should point at %s" % [entry_id, expected_path])
			return
	_failures.append("assets manifest should include %s" % entry_id)


func _assert_file_exists(path: String, message: String) -> void:
	if not FileAccess.file_exists(path):
		_failures.append(message)


func _assert_texture_node(root_node: Node, node_name: String, expected_path: String, message: String) -> TextureRect:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if not node is TextureRect:
		_failures.append("%s should be a TextureRect" % node_name)
		return null
	var texture_rect: TextureRect = node as TextureRect
	_assert_true(texture_rect.texture != null, "%s should have a texture" % node_name)
	if texture_rect.texture != null:
		_assert_true(texture_rect.texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])
	return texture_rect


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


func _wait_until_missing(root_node: Node, node_name: String, max_frames: int = 60) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) == null:
			return
		await process_frame


func _finish() -> void:
	if _failures.is_empty():
		print("BATTLE WAVE PREVIEW CLOSE FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE WAVE PREVIEW CLOSE FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
