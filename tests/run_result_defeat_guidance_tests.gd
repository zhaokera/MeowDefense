extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_defeat_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/result_defeat_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/result_defeat_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/result_defeat_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_true(FileAccess.file_exists(GUIDANCE_REFERENCE_PATH), "defeat guidance should keep an Image2 full-screen result reference")
	_assert_true(FileAccess.file_exists(GUIDANCE_SOURCE_PATH), "defeat guidance should keep the Image2-derived badge source")
	_assert_true(FileAccess.file_exists(GUIDANCE_BADGE_PATH), "defeat guidance should use a project-bound transparent Image2 badge")
	_assert_manifest_entry("result_defeat_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("result_defeat_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("result_defeat_guidance_badge", GUIDANCE_BADGE_PATH)

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

	var guidance: Control = _assert_control(instance, "ResultDefeatGuidance", "defeat result should show retry guidance")
	if guidance != null:
		_assert_true(guidance.get_meta("image2_defeat_guidance", false), "defeat guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "defeat guidance should not block result actions")
	_assert_texture_node(
		instance,
		"ResultDefeatGuidanceBadge",
		GUIDANCE_BADGE_PATH,
		"defeat guidance should render a transparent Image2 badge"
	)
	var label: Label = _assert_label(instance, "ResultDefeatGuidanceLabel", "defeat guidance should include dynamic retry copy")
	if label != null:
		_assert_true(label.text.contains("再试") or label.text.contains("守住"), "defeat guidance should point the player back to retry")
	var retry_button: Button = _assert_button(instance, "RetryButton", "defeat result should still expose retry")
	if retry_button != null:
		_assert_true(not retry_button.disabled, "retry should remain enabled while defeat guidance is visible")
	var next_button: Button = _assert_button(instance, "NextLevelButton", "defeat result should still expose locked next slot")
	if next_button != null:
		_assert_true(next_button.disabled, "defeat guidance should not unlock next level")

	instance.queue_free()

	var victory_instance: Node = scene.instantiate()
	victory_instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(victory_instance)
	await process_frame
	victory_instance.call("_show_result", true, 3, 35)
	await process_frame
	_assert_missing(victory_instance, "ResultDefeatGuidance", "victory result should not show defeat retry guidance")
	victory_instance.queue_free()

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


func _assert_control(root_node: Node, node_name: String, message: String) -> Control:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Control:
		return node as Control
	_failures.append("%s should be a Control" % node_name)
	return null


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
	var manifest: Dictionary = parsed as Dictionary
	for key: Variant in manifest.keys():
		if not (manifest[key] is Array):
			continue
		var items: Array = manifest[key] as Array
		for item: Variant in items:
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
	_clear_save_file()
	if _failures.is_empty():
		print("RESULT DEFEAT GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("RESULT DEFEAT GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear defeat guidance test save: %s" % error)
