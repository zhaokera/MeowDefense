extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_album_detail_level_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/album_detail_level_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/album_detail_level_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/album_detail_level_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "album detail level route should keep an Image2 full-screen level-select design reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "album detail level route should keep an Image2-derived badge source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "album detail level route should use a transparent runtime badge")
	_assert_manifest_entry("album_detail_level_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("album_detail_level_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("album_detail_level_guidance_badge", GUIDANCE_BADGE_PATH)

	var normal: Node = await _new_instance()
	if normal != null:
		normal.call("_show_level_select_now")
		await process_frame
		_assert_missing(normal, "AlbumDetailLevelGuidance", "normal level select should not show album detail guidance")
		_cleanup_instance(normal)

	var instance: Node = await _new_instance()
	if instance == null:
		_finish()
		return
	var album_button: Button = _assert_button(instance, "AlbumButton", "main menu should expose album entry")
	if album_button != null:
		album_button.emit_signal("pressed")
		await process_frame
	var inspect_button: Button = _assert_button(instance, "AlbumTowerInspectButton", "album tower card should be inspectable")
	if inspect_button != null:
		inspect_button.emit_signal("pressed")
		await process_frame

	var overlay: Control = _assert_control(instance, "AlbumEntryDetailOverlay", "album detail should open before route guidance is tested")
	var action: Button = _assert_button(instance, "AlbumEntryDetailActionButton", "album detail should expose level action")
	if overlay != null and action != null:
		action.emit_signal("pressed")
		_assert_true(bool(overlay.get_meta("image2_overlay_exit_animation", false)), "album detail level action should animate the Image2 detail overlay out")
		_assert_true(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "album detail overlay should ignore input while routing")
		_assert_true(action.disabled, "album detail level action should disable while routing")
		_assert_missing(instance, "LevelSelectScreen", "album detail action should not hard-cut to level select before detail exit")
		await _wait_until_missing(instance, "AlbumOverlay")
		await _wait_until_exists(instance, "LevelSelectScreen")

	_assert_missing(instance, "AlbumOverlay", "album detail action should leave album overlay")
	_assert_exists(instance, "LevelSelectScreen", "album detail action should open level select")
	var guidance: Control = _assert_control(instance, "AlbumDetailLevelGuidance", "album detail action should show a level-select guidance group")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_album_detail_level_guidance", false)), "album detail level guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "album detail level guidance should not block level buttons")
	var badge: TextureRect = _assert_texture_node(instance, "AlbumDetailLevelBadge", GUIDANCE_BADGE_PATH, "album detail level guidance should show the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "album detail level badge should not block level buttons")
	var label: Label = _assert_label(instance, "AlbumDetailLevelLabel", "album detail level guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("图鉴") or label.text.contains("关卡"), "album detail level copy should mention using the guide to choose a level")
	var start_level: Button = _assert_button(instance, "StartLevel1Button", "guided level one should remain tappable")
	if start_level != null:
		_assert_true(not start_level.disabled, "guided level one should remain enabled")

	_cleanup_instance(instance)
	_finish()


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
	await process_frame
	_clear_save_file()


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


func _assert_missing(root_node: Node, node_name: String, message: String) -> void:
	if _find_by_name(root_node, node_name) != null:
		_failures.append(message)


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


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) != null:
			return
		await process_frame


func _wait_until_missing(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) == null:
			return
		await process_frame


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("ALBUM DETAIL LEVEL GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ALBUM DETAIL LEVEL GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear album detail level guidance test save: %s" % error)
