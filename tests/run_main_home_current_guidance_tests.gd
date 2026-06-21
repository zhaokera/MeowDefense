extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_main_home_current_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/main_home_current_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/main_home_current_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/main_home_current_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "main home current guidance should keep an Image2 full-screen main-menu reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "main home current guidance should keep an Image2-derived badge source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "main home current guidance should use a transparent runtime badge")
	_assert_manifest_entry("main_home_current_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("main_home_current_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("main_home_current_guidance_badge", GUIDANCE_BADGE_PATH)

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

	var screen_before: Control = _assert_control(instance, "MainMenuScreen", "main menu should render first")
	var home_button: Button = _assert_button(instance, "BottomHomeButton", "main menu should expose the current home tab")
	if screen_before != null and home_button != null:
		home_button.emit_signal("pressed")
		await process_frame
		var screen_after: Control = _assert_control(instance, "MainMenuScreen", "home tab feedback should keep the main menu visible")
		_assert_true(screen_after == screen_before, "tapping the current home tab should not rebuild the Image2 main menu")
		if screen_after != null:
			_assert_true(not bool(screen_after.get_meta("image2_screen_exit_animation", false)), "current home tab should not start a screen exit animation")

	var guidance: Control = _assert_control(instance, "MainHomeCurrentGuidance", "current home tab should show Image2 guidance")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_main_home_current_guidance", false)), "main home guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "main home guidance should not block menu input")
	var badge: TextureRect = _assert_texture_node(instance, "MainHomeCurrentBadge", GUIDANCE_BADGE_PATH, "main home guidance should show the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "main home guidance badge should not block menu input")
	var label: Label = _assert_label(instance, "MainHomeCurrentLabel", "main home guidance should include current-tab copy")
	if label != null:
		_assert_true(label.text.contains("主城"), "main home guidance copy should confirm the current tab")
	var sub_label: Label = _assert_label(instance, "MainHomeCurrentSubLabel", "main home guidance should include next-action copy")
	if sub_label != null:
		_assert_true(sub_label.text.contains("闯关"), "main home guidance should point back to level play")
	var start_button: Button = _assert_button(instance, "StartLevelSelectButton", "main home guidance should preserve the start action")
	if start_button != null:
		_assert_true(bool(start_button.get_meta("image2_main_home_start_target", false)), "main home guidance should mark the start button as the target")
		_assert_true(not start_button.disabled, "main home guidance should leave the start button tappable")
	var glow: TextureRect = _assert_texture_node(instance, "MainHomeStartGuidanceGlow", "res://assets/generated/ui/ui_tap_feedback_paw_spark.png", "main home guidance should add an Image2 start-button glow")
	if glow != null:
		_assert_true(bool(glow.get_meta("image2_main_home_start_target", false)), "main home start glow should mark Image2 target metadata")
		_assert_true(glow.mouse_filter == Control.MOUSE_FILTER_IGNORE, "main home start glow should not block the start button")

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
			_failures.append("failed to clear main home current guidance test save: %s" % error)


func _finish(instance: Node) -> void:
	_clear_save_file()
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	if _failures.is_empty():
		print("MAIN HOME CURRENT GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("MAIN HOME CURRENT GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)
