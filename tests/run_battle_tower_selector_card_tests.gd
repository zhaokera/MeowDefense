extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

const TOWER_SELECTOR_DESIGN_PATH := "res://assets/generated/ui/battle_tower_selector_cards_design_reference.png"
const ORANGE_CARD_PATH := "res://assets/generated/ui/battle_tower_card_orange_cat.png"
const TABBY_CARD_PATH := "res://assets/generated/ui/battle_tower_card_tabby_slow_cat.png"
const SELECTED_BADGE_PATH := "res://assets/generated/ui/battle_tower_card_selected_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	await process_frame
	await physics_frame

	_assert_tower_card("orange_cat", "TowerCardOrangeCatFrame", ORANGE_CARD_PATH, true)
	_assert_tower_card("tabby_slow_cat", "TowerCardTabbySlowCatFrame", TABBY_CARD_PATH, false)
	_assert_manifest_entry("battle_tower_selector_cards_design_reference", TOWER_SELECTOR_DESIGN_PATH)
	_assert_manifest_entry("battle_tower_card_orange_cat", ORANGE_CARD_PATH)
	_assert_manifest_entry("battle_tower_card_tabby_slow_cat", TABBY_CARD_PATH)
	_assert_manifest_entry("battle_tower_card_selected_badge", SELECTED_BADGE_PATH)

	var tabby_button: Button = _assert_button(battle, "SelectTowerTabbySlowCatButton", "tabby tower card should expose a transparent hit area")
	if tabby_button != null:
		_assert_true(tabby_button.text == "", "tower card hit areas should not render visible Godot button text")
		tabby_button.emit_signal("pressed")
		await process_frame
		_assert_selected_state("TowerCardOrangeCatSelectedState", false)
		_assert_selected_state("TowerCardTabbySlowCatSelectedState", true)
		_assert_true(str(battle.get("_selected_tower_id")) == "tabby_slow_cat", "pressing the tabby card should select the tabby tower")

	var build_button: Button = _find_by_name(battle, "BuildSlot1Button") as Button
	_assert_true(build_button != null, "battle should expose a build slot hit area")
	if build_button != null:
		build_button.emit_signal("pressed")
		await process_frame
		await physics_frame
		_assert_true(not battle.towers.is_empty(), "building after selecting a tower card should create a tower")
		if not battle.towers.is_empty():
			var tower: Node = battle.towers[-1]
			_assert_true(str(tower.get("tower_id")) == "tabby_slow_cat", "selected tabby card should build the tabby slow tower")

	battle.queue_free()
	_finish()


func _assert_tower_card(tower_id: String, frame_name: String, expected_path: String, should_be_selected: bool) -> void:
	var frame: TextureRect = _assert_texture_rect(root, frame_name, expected_path, "%s should render with an Image2 tower card" % tower_id)
	if frame != null:
		_assert_true(frame.size.x >= 150.0 and frame.size.y >= 118.0, "%s card should be large enough to read and tap" % tower_id)
	var selected_name: String = _selected_state_name(tower_id)
	var selected: TextureRect = _assert_texture_rect(root, selected_name, SELECTED_BADGE_PATH, "%s should have an Image2 selected state" % tower_id)
	if selected != null:
		_assert_true(selected.visible == should_be_selected, "%s selected state visibility should match current selection" % tower_id)
	var name_label: Label = _assert_label(root, _tower_label_name(tower_id, "NameLabel"), "%s card should expose a dynamic name label" % tower_id)
	var cost_label: Label = _assert_label(root, _tower_label_name(tower_id, "CostLabel"), "%s card should expose a dynamic cost label" % tower_id)
	if name_label != null:
		_assert_true(name_label.text != "", "%s name label should not be empty" % tower_id)
	if cost_label != null:
		_assert_true(cost_label.text.contains("小鱼干") or cost_label.text.contains("60") or cost_label.text.contains("75"), "%s cost label should describe the build cost" % tower_id)


func _assert_selected_state(node_name: String, expected_visible: bool) -> void:
	var node: Node = _find_by_name(root, node_name)
	_assert_true(node is TextureRect, "%s should be an Image2 selected-state texture" % node_name)
	if node is TextureRect:
		_assert_true((node as TextureRect).visible == expected_visible, "%s visibility should update after card selection" % node_name)


func _selected_state_name(tower_id: String) -> String:
	if tower_id == "orange_cat":
		return "TowerCardOrangeCatSelectedState"
	if tower_id == "tabby_slow_cat":
		return "TowerCardTabbySlowCatSelectedState"
	return "TowerCard%sSelectedState" % tower_id.capitalize().replace("_", "")


func _tower_label_name(tower_id: String, suffix: String) -> String:
	if tower_id == "orange_cat":
		return "TowerCardOrangeCat%s" % suffix
	if tower_id == "tabby_slow_cat":
		return "TowerCardTabbySlowCat%s" % suffix
	return "TowerCard%s%s" % [tower_id.capitalize().replace("_", ""), suffix]


func _assert_texture_rect(root_node: Node, node_name: String, expected_path: String, message: String) -> TextureRect:
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


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _assert_manifest_entry(id: String, expected_path: String) -> void:
	var manifest_text: String = FileAccess.get_file_as_string("res://assets/generated/assets_manifest.json")
	if manifest_text == "":
		_failures.append("assets manifest should be readable")
		return
	var parsed: Variant = JSON.parse_string(manifest_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		_failures.append("assets manifest should parse as a dictionary")
		return
	var ui_items: Array = (parsed as Dictionary).get("ui", []) as Array
	for entry: Variant in ui_items:
		if typeof(entry) == TYPE_DICTIONARY and str(entry.get("id", "")) == id:
			_assert_true(str(entry.get("path", "")) == expected_path, "manifest entry %s should point to %s" % [id, expected_path])
			return
	_failures.append("assets manifest should include %s" % id)


func _finish() -> void:
	if _failures.is_empty():
		print("BATTLE TOWER SELECTOR CARD TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE TOWER SELECTOR CARD TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
