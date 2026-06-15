extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_locked_level_feedback_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const LOCKED_LEVEL_FEEDBACK_DESIGN_PATH := "res://assets/generated/ui/locked_level_feedback_design_reference.png"
const LOCKED_LEVEL_FEEDBACK_BURST_PATH := "res://assets/generated/ui/locked_level_feedback_burst.png"
const LOCKED_LEVEL_FEEDBACK_BURST_SOURCE_PATH := "res://assets/generated/ui/locked_level_feedback_burst_source.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish()
		return
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame

	instance.call("_show_level_select")
	await process_frame
	var locked_start: Button = _assert_button(instance, "StartLevel2Button", "level two start button should exist")
	if locked_start != null:
		_assert_true(locked_start.disabled, "locked level start button should stay disabled")
	_assert_texture_node(
		instance,
		"Level2LockedBadge",
		"res://assets/generated/ui/level_lock_badge.png",
		"locked level should keep the Image2 lock badge"
	)
	var locked_info: Button = _assert_button(instance, "LockedLevel2InfoButton", "locked level card should expose a feedback hit area")
	if locked_info != null:
		_assert_true(not locked_info.disabled, "locked level feedback hit area should be tappable")
		locked_info.emit_signal("pressed")
		await process_frame
		await process_frame

	_assert_exists(instance, "LockedLevelFeedbackOverlay", "tapping a locked level should open a feedback overlay")
	_assert_texture_node(
		instance,
		"LockedLevelFeedbackDesignBackground",
		LOCKED_LEVEL_FEEDBACK_DESIGN_PATH,
		"locked level feedback should render from its Image2 full-screen design"
	)
	_assert_texture_node(
		instance,
		"LockedLevelFeedbackBurst",
		LOCKED_LEVEL_FEEDBACK_BURST_PATH,
		"locked level feedback should include the Image2 locked burst asset"
	)
	var title: Label = _assert_label(instance, "LockedLevelFeedbackTitle", "locked level feedback should name the locked level")
	if title != null:
		_assert_true(title.text.contains("第 2 关"), "locked level feedback title should mention level two")
	var requirement: Label = _assert_label(instance, "LockedLevelFeedbackRequirement", "locked level feedback should explain the unlock condition")
	if requirement != null:
		_assert_true(requirement.text.contains("第 1 关"), "locked level feedback should point to the previous level")
	var close_button: Button = _assert_button(instance, "CloseLockedLevelFeedbackButton", "locked level feedback should be closable")
	if close_button != null:
		close_button.emit_signal("pressed")
		await process_frame
		_assert_missing(instance, "LockedLevelFeedbackOverlay", "closing locked level feedback should remove it")

	if locked_info != null:
		locked_info.emit_signal("pressed")
		await process_frame
	var action_button: Button = _assert_button(instance, "PlayPreviousLevelButton", "locked level feedback should offer the previous level")
	if action_button != null:
		action_button.emit_signal("pressed")
		await process_frame
		_assert_exists(instance, "BattleScene", "locked level guidance should start the previous level")
		_assert_true(_as_int(instance.get("_current_level_id")) == 1, "locked level guidance should target level one for level two")

	_assert_manifest_entry("locked_level_feedback_design_reference", LOCKED_LEVEL_FEEDBACK_DESIGN_PATH)
	_assert_manifest_entry("locked_level_feedback_burst_source", LOCKED_LEVEL_FEEDBACK_BURST_SOURCE_PATH)
	_assert_manifest_entry("locked_level_feedback_burst", LOCKED_LEVEL_FEEDBACK_BURST_PATH)

	instance.queue_free()
	_finish()


func _as_int(value: Variant) -> int:
	if value == null:
		return 0
	return int(value)


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


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("LOCKED LEVEL FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("LOCKED LEVEL FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear locked level feedback test save: %s" % error)
