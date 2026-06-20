extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_settings_saved_feedback_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const FEEDBACK_REFERENCE_PATH := "res://assets/generated/ui/settings_saved_feedback_design_reference.png"
const FEEDBACK_SOURCE_PATH := "res://assets/generated/ui/settings_saved_feedback_badge_source.png"
const FEEDBACK_BADGE_PATH := "res://assets/generated/ui/settings_saved_feedback_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(FEEDBACK_REFERENCE_PATH, "settings saved feedback should keep an Image2 full-screen design reference")
	_assert_file_exists(FEEDBACK_SOURCE_PATH, "settings saved feedback should keep an Image2-derived badge source")
	_assert_file_exists(FEEDBACK_BADGE_PATH, "settings saved feedback should use a transparent runtime badge")
	_assert_manifest_entry("settings_saved_feedback_design_reference", FEEDBACK_REFERENCE_PATH)
	_assert_manifest_entry("settings_saved_feedback_badge_source", FEEDBACK_SOURCE_PATH)
	_assert_manifest_entry("settings_saved_feedback_badge", FEEDBACK_BADGE_PATH)

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

	var main_screen: Control = _find_by_name(instance, "MainMenuScreen") as Control
	if main_screen == null:
		_failures.append("main menu screen should exist")
		_finish(instance)
		return
	instance.set("_music_enabled", true)
	instance.set("_effects_enabled", true)
	instance.set("_volume", 82.0)
	instance.call("_show_settings_overlay", main_screen)
	await process_frame

	var music_toggle: CheckButton = _assert_button(instance, "MusicToggle", "settings should expose the music toggle") as CheckButton
	if music_toggle != null:
		music_toggle.button_pressed = false
		await process_frame
		await process_frame
		_assert_true(not bool(instance.get("_music_enabled")), "music toggle should update the saved setting")
		_assert_saved_feedback(instance, "音乐")

	var effects_toggle: CheckButton = _assert_button(instance, "EffectsToggle", "settings should keep effects toggle usable under saved feedback") as CheckButton
	if effects_toggle != null:
		_assert_true(not effects_toggle.disabled, "settings saved feedback should not disable nearby toggles")

	var volume_slider: HSlider = _find_by_name(instance, "VolumeSlider") as HSlider
	if volume_slider == null:
		_failures.append("settings should expose the volume slider")
	else:
		volume_slider.value = 35.0
		await process_frame
		_assert_true(abs(float(instance.get("_volume")) - 35.0) < 0.01, "volume slider should update the saved volume")
		_assert_saved_feedback(instance, "音量")

	_finish(instance)


func _assert_saved_feedback(root_node: Node, expected_copy: String) -> void:
	var feedback: Control = _assert_control(root_node, "SettingsSavedFeedback", "changing %s settings should show a saved feedback badge" % expected_copy)
	if feedback != null:
		_assert_true(bool(feedback.get_meta("image2_settings_saved_feedback", false)), "settings saved feedback should mark Image2 metadata")
		_assert_true(feedback.mouse_filter == Control.MOUSE_FILTER_IGNORE, "settings saved feedback should not block controls")
	var badge: TextureRect = _assert_texture_node(root_node, "SettingsSavedFeedbackBadge", FEEDBACK_BADGE_PATH, "settings saved feedback should render the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "settings saved feedback badge should not block controls")
	var label: Label = _assert_label(root_node, "SettingsSavedFeedbackLabel", "settings saved feedback should include runtime copy")
	if label != null:
		_assert_true(label.text.contains(expected_copy) and (label.text.contains("保存") or label.text.contains("生效")), "settings saved feedback copy should name the changed setting")


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
		_failures.append("assets manifest should parse as an object")
		return
	var assets: Variant = (data as Dictionary).get("ui", [])
	if not assets is Array:
		_failures.append("assets manifest should contain a ui array")
		return
	for entry: Variant in assets as Array:
		if entry is Dictionary and str((entry as Dictionary).get("id", "")) == entry_id:
			_assert_true(str((entry as Dictionary).get("path", "")) == expected_path, "%s should point at %s" % [entry_id, expected_path])
			return
	_failures.append("assets manifest should include %s" % entry_id)


func _assert_file_exists(path: String, message: String) -> void:
	if not FileAccess.file_exists(path):
		_failures.append(message)


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_control(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
	return null


func _assert_control(root_node: Node, node_name: String, message: String) -> Control:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
		return null
	if node is Control:
		return node as Control
	_failures.append("%s should be a Control" % node_name)
	return null


func _assert_texture_node(root_node: Node, node_name: String, expected_path: String, message: String) -> TextureRect:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
		return null
	if not node is TextureRect:
		_failures.append("%s should be a TextureRect" % node_name)
		return null
	var texture_node: TextureRect = node as TextureRect
	if texture_node.texture == null:
		_failures.append("%s should have a texture" % node_name)
	elif texture_node.texture.resource_path != expected_path:
		_failures.append("%s should use %s" % [node_name, expected_path])
	return texture_node


func _assert_label(root_node: Node, node_name: String, message: String) -> Label:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
		return null
	if node is Label:
		return node as Label
	_failures.append("%s should be a Label" % node_name)
	return null


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear settings saved feedback test save: %s" % error)


func _finish(instance: Node) -> void:
	_clear_save_file()
	if instance != null:
		instance.queue_free()
	if _failures.is_empty():
		print("SETTINGS SAVED FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SETTINGS SAVED FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
