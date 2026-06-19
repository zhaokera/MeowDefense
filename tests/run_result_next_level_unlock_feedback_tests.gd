extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_result_next_level_unlock_feedback_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const UNLOCK_REFERENCE_PATH := "res://assets/generated/ui/result_next_level_unlock_design_reference.png"
const UNLOCK_SOURCE_PATH := "res://assets/generated/ui/result_next_level_unlock_burst_source.png"
const UNLOCK_BURST_PATH := "res://assets/generated/ui/result_next_level_unlock_burst.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_true(FileAccess.file_exists(UNLOCK_REFERENCE_PATH), "next-level unlock should keep an Image2 full-screen result reference")
	_assert_true(FileAccess.file_exists(UNLOCK_SOURCE_PATH), "next-level unlock should keep the Image2 source burst")
	_assert_true(FileAccess.file_exists(UNLOCK_BURST_PATH), "next-level unlock should use a project-bound transparent Image2 burst")
	_assert_manifest_entry("result_next_level_unlock_design_reference", UNLOCK_REFERENCE_PATH)
	_assert_manifest_entry("result_next_level_unlock_burst_source", UNLOCK_SOURCE_PATH)
	_assert_manifest_entry("result_next_level_unlock_burst", UNLOCK_BURST_PATH)

	await _assert_first_clear_shows_unlock_feedback()
	await _assert_replay_does_not_repeat_unlock_feedback()
	_finish()


func _assert_first_clear_shows_unlock_feedback() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_current_level_id", 1)
	instance.set("_unlocked_level", 1)
	instance.call("_show_result", true, 3, 35)
	await process_frame

	_assert_true(int(instance.get("_unlocked_level")) == 2, "first clear should unlock level two")
	var feedback: TextureRect = _assert_texture_node(
		instance,
		"ResultNextLevelUnlockFeedback",
		UNLOCK_BURST_PATH,
		"first clear should show an Image2 next-level unlock burst"
	)
	if feedback != null:
		_assert_true(feedback.z_index > 0, "next-level unlock feedback should render above the result screen art")
	var title: Label = _assert_label(instance, "ResultNextLevelUnlockTitle", "unlock feedback should include a title")
	if title != null:
		_assert_true(title.text.contains("新关卡"), "unlock feedback title should explain that a new level opened")
	var detail: Label = _assert_label(instance, "ResultNextLevelUnlockDetail", "unlock feedback should include dynamic level detail")
	if detail != null:
		_assert_true(detail.text.contains("第 2 关"), "unlock feedback should identify the newly opened level")
		_assert_true(detail.text.contains("奶酪森林"), "unlock feedback should include the newly opened level name")
	var next_button: Button = _assert_button(instance, "NextLevelButton", "result screen should still expose next-level action")
	if next_button != null:
		_assert_true(not next_button.disabled, "newly unlocked next level should be playable from result screen")
	_cleanup_instance(instance)


func _assert_replay_does_not_repeat_unlock_feedback() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_current_level_id", 1)
	instance.set("_unlocked_level", 2)
	instance.call("_show_result", true, 3, 35)
	await process_frame

	_assert_missing(instance, "ResultNextLevelUnlockFeedback", "replaying an already unlocked level should not repeat new-level feedback")
	_assert_true(int(instance.get("_unlocked_level")) == 2, "replay should preserve the unlocked level")
	_cleanup_instance(instance)


func _new_instance() -> Node:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		return null
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame
	return instance


func _cleanup_instance(instance: Node) -> void:
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	_clear_save_file()


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


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear next-level unlock feedback test save: %s" % error)


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("RESULT NEXT LEVEL UNLOCK FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("RESULT NEXT LEVEL UNLOCK FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
