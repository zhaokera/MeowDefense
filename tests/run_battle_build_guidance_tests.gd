extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/battle_build_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/battle_build_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/battle_build_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_true(FileAccess.file_exists(GUIDANCE_REFERENCE_PATH), "build guidance should keep an Image2 full-screen battle reference")
	_assert_true(FileAccess.file_exists(GUIDANCE_SOURCE_PATH), "build guidance should keep the Image2-derived badge source")
	_assert_true(FileAccess.file_exists(GUIDANCE_BADGE_PATH), "build guidance should use a project-bound transparent Image2 badge")
	_assert_manifest_entry("battle_build_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("battle_build_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("battle_build_guidance_badge", GUIDANCE_BADGE_PATH)

	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var hint: Control = _assert_control(battle, "BattleBuildGuidanceHint", "battle should show first-build guidance before any tower is built")
	if hint != null:
		_assert_true(hint.get_meta("image2_build_guidance", false), "build guidance should mark Image2 metadata")
		_assert_true(hint.mouse_filter == Control.MOUSE_FILTER_IGNORE, "build guidance should not block build-slot input")
	_assert_texture_node(
		battle,
		"BattleBuildGuidanceBadge",
		GUIDANCE_BADGE_PATH,
		"build guidance should render a transparent Image2 badge"
	)
	var label: Label = _assert_label(battle, "BattleBuildGuidanceLabel", "build guidance should include runtime guidance copy")
	if label != null:
		_assert_true(label.text.contains("建造"), "build guidance should tell the player to build")

	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "first build slot should remain tappable under guidance")
	var coins_before: int = int(battle.get("coins"))
	if build_button != null:
		_assert_true(not build_button.disabled, "first build slot button should be enabled while guidance is visible")
		build_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	await process_frame

	_assert_true(int(battle.towers.size()) == 1, "pressing the highlighted build slot should still build a tower")
	_assert_true(int(battle.get("coins")) < coins_before, "building through guidance should spend fish")
	_assert_missing(battle, "BattleBuildGuidanceHint", "build guidance should disappear after the first tower is built")

	battle.queue_free()
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
	if _failures.is_empty():
		print("BATTLE BUILD GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE BUILD GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)
