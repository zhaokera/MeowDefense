extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_result_test_save.json"

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

	instance.call("_show_result", true, 3, 105)
	await process_frame

	_assert_exists(instance, "ResultScreen", "result screen should open")
	_assert_texture_node(
		instance,
		"ResultDesignBackground",
		"res://assets/generated/ui/result_screen_design_reference.png",
		"result screen should use the full Image2 result design"
	)
	_assert_texture_node(
		instance,
		"ResultRetryFrame",
		"res://assets/generated/ui/result_button_orange.png",
		"retry should use an Image2 button frame"
	)
	_assert_texture_node(
		instance,
		"ResultLevelsFrame",
		"res://assets/generated/ui/result_button_blue.png",
		"level-map action should use an Image2 button frame"
	)
	_assert_texture_node(
		instance,
		"ResultNextFrame",
		"res://assets/generated/ui/result_button_green.png",
		"next-level action should use an Image2 button frame"
	)
	_assert_missing(instance, "ResultPanel", "result screen should not render the old code-drawn panel")
	_assert_missing(instance, "ResourceStrip", "result screen should not render the old code-drawn resource strip")
	_assert_exists(instance, "FishCounter", "result screen should show dynamic fish counter")
	_assert_exists(instance, "BestStarsCounter", "result screen should show dynamic best stars")
	_assert_exists(instance, "ProgressCounter", "result screen should show dynamic level progress")

	_assert_button(instance, "RetryButton", "result screen should expose retry")
	var levels_button: Button = _assert_button(instance, "ResultLevelsButton", "result screen should expose level map")
	_assert_button(instance, "NextLevelButton", "result screen should expose next level")
	if levels_button != null:
		levels_button.emit_signal("pressed")
		await process_frame
		_assert_exists(instance, "LevelSelectScreen", "result level-map button should return to level select")

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
		print("RESULT SCREEN TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("RESULT SCREEN TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear result test save: %s" % error)
