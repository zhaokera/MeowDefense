extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const PAUSE_RESUME_REFERENCE_PATH := "res://assets/generated/ui/pause_resume_feedback_design_reference.png"
const PAUSE_RESUME_BADGE_SOURCE_PATH := "res://assets/generated/ui/pause_resume_feedback_badge_source.png"
const PAUSE_RESUME_BADGE_PATH := "res://assets/generated/ui/pause_resume_feedback_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_file_exists(PAUSE_RESUME_REFERENCE_PATH, "pause resume feedback should keep an Image2 design reference")
	_assert_file_exists(PAUSE_RESUME_BADGE_SOURCE_PATH, "pause resume feedback should keep its Image2-derived source asset")
	_assert_file_exists(PAUSE_RESUME_BADGE_PATH, "pause resume feedback should use a transparent runtime badge")
	_assert_manifest_entry("pause_resume_feedback_design_reference", PAUSE_RESUME_REFERENCE_PATH)
	_assert_manifest_entry("pause_resume_feedback_badge_source", PAUSE_RESUME_BADGE_SOURCE_PATH)
	_assert_manifest_entry("pause_resume_feedback_badge", PAUSE_RESUME_BADGE_PATH)

	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var pause_button: Button = _assert_button(battle, "PauseButton", "battle HUD should expose pause")
	if pause_button != null:
		pause_button.emit_signal("pressed")
	await process_frame
	_assert_true(paused, "pause action should pause the scene tree")

	var resume_button: Button = _assert_button(battle, "ResumeButton", "pause menu should expose resume")
	if resume_button != null:
		resume_button.emit_signal("pressed")
	_assert_true(not paused, "resume action should immediately unpause the scene tree")
	for _frame: int in range(28):
		await process_frame

	_assert_true(_find_by_name(battle, "PauseMenuOverlay") == null, "pause menu overlay should leave before resume feedback appears")
	var feedback: TextureRect = _assert_texture_node(
		battle,
		"PauseResumeFeedback",
		PAUSE_RESUME_BADGE_PATH,
		"pause resume should show an Image2 continue feedback badge after overlay exit"
	)
	if feedback != null:
		_assert_true(bool(feedback.get_meta("image2_pause_resume_feedback", false)), "pause resume feedback should mark Image2 metadata")
		_assert_true(feedback.mouse_filter == Control.MOUSE_FILTER_IGNORE, "pause resume feedback should not block battle input")
	var label: Label = _assert_label(battle, "PauseResumeFeedbackLabel", "pause resume feedback should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("继续守卫"), "pause resume feedback should tell the player the battle continued")
	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "resumed battle should keep build controls available")
	if build_button != null:
		_assert_true(not build_button.disabled, "build controls should remain usable after resume feedback appears")

	battle.queue_free()
	paused = false
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
		print("PAUSE RESUME FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("PAUSE RESUME FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
