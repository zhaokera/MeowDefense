extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_level_select_new_unlock_hint_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const NEW_UNLOCK_REFERENCE_PATH := "res://assets/generated/ui/level_select_new_unlock_design_reference.png"
const NEW_UNLOCK_SOURCE_PATH := "res://assets/generated/ui/level_select_new_unlock_hint_source.png"
const NEW_UNLOCK_HINT_PATH := "res://assets/generated/ui/level_select_new_unlock_hint.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_true(FileAccess.file_exists(NEW_UNLOCK_REFERENCE_PATH), "level select new-unlock hint should keep an Image2 full-screen level-select reference")
	_assert_true(FileAccess.file_exists(NEW_UNLOCK_SOURCE_PATH), "level select new-unlock hint should keep the Image2 source badge")
	_assert_true(FileAccess.file_exists(NEW_UNLOCK_HINT_PATH), "level select new-unlock hint should use a project-bound transparent Image2 badge")
	_assert_manifest_entry("level_select_new_unlock_design_reference", NEW_UNLOCK_REFERENCE_PATH)
	_assert_manifest_entry("level_select_new_unlock_hint_source", NEW_UNLOCK_SOURCE_PATH)
	_assert_manifest_entry("level_select_new_unlock_hint", NEW_UNLOCK_HINT_PATH)

	await _assert_newly_unlocked_level_is_highlighted()
	await _assert_cleared_unlocked_level_is_not_highlighted()
	_finish()


func _assert_newly_unlocked_level_is_highlighted() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_unlocked_level", 2)
	instance.set("_best_stars_by_level", {1: 3})
	instance.call("_show_level_select_now")
	await process_frame

	_assert_missing(instance, "Level1NewUnlockHint", "already cleared level one should not show a new-unlock hint")
	var hint: TextureRect = _assert_texture_node(
		instance,
		"Level2NewUnlockHint",
		NEW_UNLOCK_HINT_PATH,
		"newly unlocked level two should show an Image2 hint"
	)
	if hint != null:
		_assert_true(hint.z_index > 0, "new-unlock hint should render above level-select art")
		_assert_true(hint.get_meta("image2_new_unlock_hint", false), "new-unlock hint should mark Image2 metadata")
	var label: Label = _assert_label(instance, "Level2NewUnlockLabel", "new-unlock hint should include a runtime label")
	if label != null:
		_assert_true(label.text.contains("新关卡"), "new-unlock label should identify the newly opened level")
	_assert_missing(instance, "Level3NewUnlockHint", "locked level three should not show a new-unlock hint")
	_assert_texture_node(
		instance,
		"Level3LockedBadge",
		"res://assets/generated/ui/level_lock_badge.png",
		"locked level three should still show the Image2 lock badge"
	)
	var level_two_button: Button = _assert_button(instance, "StartLevel2Button", "newly unlocked level two should stay playable")
	if level_two_button != null:
		_assert_true(not level_two_button.disabled, "newly unlocked level two button should be enabled")
	_cleanup_instance(instance)


func _assert_cleared_unlocked_level_is_not_highlighted() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_unlocked_level", 3)
	instance.set("_best_stars_by_level", {1: 3, 2: 2})
	instance.call("_show_level_select_now")
	await process_frame

	_assert_missing(instance, "Level2NewUnlockHint", "cleared level two should not keep the new-unlock hint")
	var hint: TextureRect = _assert_texture_node(
		instance,
		"Level3NewUnlockHint",
		NEW_UNLOCK_HINT_PATH,
		"highest unlocked uncleared level three should show a new-unlock hint"
	)
	if hint != null:
		_assert_true(hint.get_meta("image2_new_unlock_hint", false), "level three new-unlock hint should mark Image2 metadata")
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
			_failures.append("failed to clear level select new-unlock hint test save: %s" % error)


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("LEVEL SELECT NEW UNLOCK HINT TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("LEVEL SELECT NEW UNLOCK HINT TESTS FAIL: %d" % _failures.size())
		quit(1)
