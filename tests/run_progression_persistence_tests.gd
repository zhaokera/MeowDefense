extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_progression_test_save.json"
const LOCK_BADGE_PATH := "res://assets/generated/ui/level_lock_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file(TEST_SAVE_PATH)

	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish()
		return

	var first_instance: Node = scene.instantiate()
	first_instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(first_instance)
	await process_frame

	first_instance.call("_show_level_select_now")
	await process_frame
	_assert_button_enabled(first_instance, "StartLevel1Button", true, "fresh progress should unlock level one")
	_assert_button_enabled(first_instance, "StartLevel2Button", false, "fresh progress should lock level two")
	_assert_lock_badge(first_instance, 2, "locked level two should show an Image2 lock badge")

	first_instance.set("_current_level_id", 1)
	first_instance.call("_show_result", true, 3, 35)
	await process_frame
	_assert_true(FileAccess.file_exists(TEST_SAVE_PATH), "winning a level should persist progress to user save")
	first_instance.queue_free()
	await process_frame

	var second_instance: Node = scene.instantiate()
	second_instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(second_instance)
	await process_frame
	second_instance.call("_show_level_select_now")
	await process_frame

	_assert_true(int(second_instance.call("_level_stars", 1)) == 3, "saved progress should restore best stars for level one")
	_assert_true(int(second_instance.get("_total_fish")) >= 35, "saved progress should restore fish rewards")
	_assert_button_enabled(second_instance, "StartLevel2Button", true, "clearing level one should unlock level two")
	_assert_missing(second_instance, "Level2LockedBadge", "unlocked level two should not show the lock badge")
	_assert_button_enabled(second_instance, "StartLevel3Button", false, "level three should remain locked until level two is cleared")
	_assert_lock_badge(second_instance, 3, "locked level three should show an Image2 lock badge")

	second_instance.queue_free()
	_clear_save_file(TEST_SAVE_PATH)
	_finish()


func _clear_save_file(save_path: String) -> void:
	if FileAccess.file_exists(save_path):
		var absolute_path: String = ProjectSettings.globalize_path(save_path)
		var error: Error = DirAccess.remove_absolute(absolute_path)
		if error != OK:
			_failures.append("failed to clear existing save file: %s" % error)


func _assert_button_enabled(root_node: Node, node_name: String, expected_enabled: bool, message: String) -> void:
	var button: Button = _assert_button(root_node, node_name, message)
	if button == null:
		return
	_assert_true(button.disabled != expected_enabled, message)


func _assert_lock_badge(root_node: Node, level_id: int, message: String) -> void:
	var node_name: String = "Level%dLockedBadge" % level_id
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return
	if not node is TextureRect:
		_failures.append("%s should be a TextureRect" % node_name)
		return
	var badge: TextureRect = node as TextureRect
	if badge.texture == null:
		_failures.append("%s should have an Image2 texture" % node_name)
		return
	_assert_true(badge.texture.resource_path == LOCK_BADGE_PATH, "%s should use %s" % [node_name, LOCK_BADGE_PATH])


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
	if _failures.is_empty():
		print("PROGRESSION PERSISTENCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("PROGRESSION PERSISTENCE TESTS FAIL: %d" % _failures.size())
		quit(1)
