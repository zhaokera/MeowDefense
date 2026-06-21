extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_level_select_current_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/level_select_current_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/level_select_current_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/level_select_current_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "level-select current guidance should keep an Image2 full-screen level-map reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "level-select current guidance should keep an Image2-derived badge source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "level-select current guidance should use a transparent runtime badge")
	_assert_manifest_entry("level_select_current_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("level_select_current_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("level_select_current_guidance_badge", GUIDANCE_BADGE_PATH)

	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish(null)
		return
	var instance: Node = scene.instantiate()
	if instance == null:
		_failures.append("main scene should instantiate")
		_finish(null)
		return
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame
	instance.call("_show_level_select_now")
	await process_frame

	var screen_before: Control = _assert_control(instance, "LevelSelectScreen", "level select should be visible before current-tab feedback")
	var levels_button: Button = _assert_button(instance, "BottomLevelsButton", "level select should expose the current levels tab")
	if screen_before != null and levels_button != null:
		levels_button.emit_signal("pressed")
		await process_frame
		var screen_after: Control = _assert_control(instance, "LevelSelectScreen", "levels tab feedback should keep the level-select screen visible")
		_assert_true(screen_after == screen_before, "tapping the current levels tab should not rebuild the Image2 level-select screen")
		if screen_after != null:
			_assert_true(not bool(screen_after.get_meta("image2_screen_exit_animation", false)), "current levels tab should not start a screen exit animation")

	var guidance: Control = _assert_control(instance, "LevelSelectCurrentGuidance", "current levels tab should show Image2 guidance")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_level_select_current_guidance", false)), "level-select current guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "level-select current guidance should not block level input")
	var badge: TextureRect = _assert_texture_node(instance, "LevelSelectCurrentBadge", GUIDANCE_BADGE_PATH, "level-select current guidance should show the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "level-select current badge should not block level input")
	var label: Label = _assert_label(instance, "LevelSelectCurrentLabel", "level-select current guidance should include current-tab copy")
	if label != null:
		_assert_true(label.text.contains("关卡"), "level-select current guidance copy should confirm the current tab")
	var sub_label: Label = _assert_label(instance, "LevelSelectCurrentSubLabel", "level-select current guidance should include next-action copy")
	if sub_label != null:
		_assert_true(sub_label.text.contains("开局") or sub_label.text.contains("出发"), "level-select current guidance should point to starting a level")
	var start_button: Button = _assert_button(instance, "StartLevel1Button", "level-select current guidance should preserve level-one start")
	if start_button != null:
		_assert_true(bool(start_button.get_meta("image2_level_select_current_target", false)), "level-select current guidance should mark level one as the target")
		_assert_true(not start_button.disabled, "level-select current guidance should leave level one tappable")
	var glow: TextureRect = _assert_texture_node(instance, "LevelSelectCurrentStartGlow", "res://assets/generated/ui/ui_tap_feedback_paw_spark.png", "level-select current guidance should add an Image2 level-card glow")
	if glow != null:
		_assert_true(bool(glow.get_meta("image2_level_select_current_target", false)), "level-select current glow should mark Image2 target metadata")
		_assert_true(glow.mouse_filter == Control.MOUSE_FILTER_IGNORE, "level-select current glow should not block level one")

	_finish(instance)


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


func _assert_control(root_node: Node, node_name: String, message: String) -> Control:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Control:
		return node as Control
	_failures.append("%s should be a Control" % node_name)
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
	if node == null:
		return null
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
			_failures.append("failed to clear level-select current guidance test save: %s" % error)


func _finish(instance: Node) -> void:
	_clear_save_file()
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	if _failures.is_empty():
		print("LEVEL SELECT CURRENT GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("LEVEL SELECT CURRENT GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)
