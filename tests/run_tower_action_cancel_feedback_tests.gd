extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const CANCEL_REFERENCE_PATH := "res://assets/generated/ui/tower_action_cancel_feedback_design_reference.png"
const CANCEL_SOURCE_PATH := "res://assets/generated/ui/tower_action_cancel_feedback_badge_source.png"
const CANCEL_BADGE_PATH := "res://assets/generated/ui/tower_action_cancel_feedback_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_file_exists(CANCEL_REFERENCE_PATH, "tower action cancel should have a project-bound Image2 design reference")
	_assert_file_exists(CANCEL_SOURCE_PATH, "tower action cancel should keep its Image2-derived source asset")
	_assert_file_exists(CANCEL_BADGE_PATH, "tower action cancel should have a transparent runtime badge")
	_assert_manifest_entry("tower_action_cancel_feedback_design_reference", CANCEL_REFERENCE_PATH)
	_assert_manifest_entry("tower_action_cancel_feedback_badge_source", CANCEL_SOURCE_PATH)
	_assert_manifest_entry("tower_action_cancel_feedback_badge", CANCEL_BADGE_PATH)

	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "battle should expose first build slot")
	if build_button == null:
		_finish(battle)
		return
	build_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	_assert_true(int(battle.towers.size()) == 1, "test setup should build exactly one tower")
	var coins_after_build: int = int(battle.coins)

	build_button = _assert_button(battle, "BuildSlot1Button", "occupied slot should stay tappable")
	if build_button == null:
		_finish(battle)
		return
	build_button.emit_signal("pressed")
	await process_frame

	var close_button: Button = _assert_button(battle, "CloseTowerActionButton", "tower action panel should expose close")
	var overlay: Control = _assert_control(battle, "TowerActionOverlay", "tower action overlay should be visible before cancel")
	if close_button != null:
		close_button.emit_signal("pressed")
		await process_frame

	_assert_true(int(battle.towers.size()) == 1, "canceling tower actions should not remove the tower")
	_assert_true(int(battle.coins) == coins_after_build, "canceling tower actions should not spend or refund fish")
	if overlay != null and is_instance_valid(overlay):
		_assert_true(overlay.get_meta("image2_overlay_exit_animation", false), "cancel should keep the Image2 overlay exit animation")
	var feedback: TextureRect = _assert_texture_node(
		battle,
		"TowerActionCancelFeedback",
		CANCEL_BADGE_PATH,
		"canceling tower actions should show an Image2 cancel feedback badge"
	)
	if feedback != null:
		_assert_true(bool(feedback.get_meta("image2_tower_action_cancel_feedback", false)), "cancel feedback should be marked as Image2-sourced")
		_assert_true(feedback.mouse_filter == Control.MOUSE_FILTER_IGNORE, "cancel feedback should not block battle input")
	var label: Label = _assert_label(battle, "TowerActionCancelFeedbackLabel", "cancel feedback should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("继续") or label.text.contains("取消"), "cancel copy should tell the player they can continue")

	for _frame: int in range(45):
		await process_frame
	_assert_missing(battle, "TowerActionOverlay", "tower action overlay should be removed after cancel exit animation")
	_assert_true(int(battle.towers.size()) == 1, "tower should remain after cancel feedback animation starts")

	_finish(battle)


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


func _assert_control(root_node: Node, node_name: String, message: String) -> Control:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Control:
		return node as Control
	_failures.append("%s should be a Control" % node_name)
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


func _finish(battle: Node) -> void:
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	if _failures.is_empty():
		print("TOWER ACTION CANCEL FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("TOWER ACTION CANCEL FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
