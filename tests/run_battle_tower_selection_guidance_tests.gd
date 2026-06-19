extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/battle_tower_selection_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/battle_tower_selection_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/battle_tower_selection_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "tower selection guidance should have a project-bound Image2 design reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "tower selection guidance should keep its Image2-derived source asset")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "tower selection guidance should have a transparent runtime badge")
	_assert_manifest_entry("battle_tower_selection_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("battle_tower_selection_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("battle_tower_selection_guidance_badge", GUIDANCE_BADGE_PATH)

	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	await process_frame
	await physics_frame

	_assert_missing(battle, "BattleTowerSelectionGuidance", "selection guidance should not show before the player changes tower cards")

	var tabby_button: Button = _assert_button(battle, "SelectTowerTabbySlowCatButton", "tabby tower card should expose a transparent hit area")
	if tabby_button != null:
		tabby_button.emit_signal("pressed")
		await process_frame

	var guidance: Control = _assert_control(battle, "BattleTowerSelectionGuidance", "selecting a tower card should show placement guidance near an empty build slot")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_tower_selection_guidance", false)), "tower selection guidance should be marked as Image2-sourced")
		_assert_true(str(guidance.get_meta("tower_id", "")) == "tabby_slow_cat", "guidance should remember the selected tower id")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "tower selection guidance should not block build slot input")
	var badge: TextureRect = _assert_texture_node(
		battle,
		"BattleTowerSelectionGuidanceBadge",
		GUIDANCE_BADGE_PATH,
		"tower selection guidance should render the Image2 badge"
	)
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "guidance badge should not catch input")
	var label: Label = _assert_label(battle, "BattleTowerSelectionGuidanceLabel", "tower selection guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("猫爪") or label.text.contains("放置"), "guidance copy should tell the player to place on a paw slot")

	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "first build slot should remain tappable under selection guidance")
	if build_button != null:
		_assert_true(not build_button.disabled, "guided build slot should not be disabled")
		build_button.emit_signal("pressed")
		await process_frame
		await physics_frame
		await process_frame

	_assert_missing(battle, "BattleTowerSelectionGuidance", "tower selection guidance should disappear after building the selected tower")
	_assert_true(int(battle.towers.size()) == 1, "building after selection guidance should create one tower")
	if not battle.towers.is_empty():
		var tower: Node = battle.towers[0]
		_assert_true(str(tower.get("tower_id")) == "tabby_slow_cat", "guided build should use the selected tabby tower")

	battle.queue_free()
	_finish()


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


func _assert_control(root_node: Node, node_name: String, message: String) -> Control:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Control:
		return node as Control
	_failures.append("%s should be a Control" % node_name)
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
		print("BATTLE TOWER SELECTION GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE TOWER SELECTION GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)
