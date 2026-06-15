extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_defeat_result_test_save.json"

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

	instance.set("_current_level_id", 1)
	instance.call("_show_result", false, 0, 0)
	await process_frame

	_assert_exists(instance, "ResultScreen", "defeat result screen should open")
	_assert_texture_node(
		instance,
		"ResultDesignBackground",
		"res://assets/generated/ui/result_screen_defeat_design_reference.png",
		"defeat result should use a dedicated Image2 defeat design"
	)
	var title: Label = _assert_label(instance, "ResultTitle", "defeat result should explain the failure")
	if title != null:
		_assert_true(title.text.contains("偷空") or title.text.contains("失败"), "defeat title should communicate failure")
	var next_button: Button = _assert_button(instance, "NextLevelButton", "defeat result should still expose next action slot")
	if next_button != null:
		_assert_true(next_button.disabled, "defeat should not allow advancing to the next locked level")
	_assert_missing(instance, "ResultNextFrame", "defeat result should not overlay the victory next-level button frame")
	_assert_missing(instance, "ResultRewardCelebrationLayer", "defeat result should not show victory reward celebration")
	_assert_true(int(instance.get("_unlocked_level")) == 1, "defeat should not unlock the next level")
	_assert_true(int(instance.get("_total_fish")) == 0, "defeat with zero reward should not grant fish")
	_assert_true(int(instance.call("_level_stars", 1)) == 0, "defeat should not record stars")

	instance.queue_free()
	_finish()


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
		print("RESULT DEFEAT SCREEN TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("RESULT DEFEAT SCREEN TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear defeat result test save: %s" % error)
