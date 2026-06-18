extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

const SHORTAGE_STAMP_PATH := "res://assets/generated/ui/battle_tower_card_insufficient_fish_stamp.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	await process_frame
	await physics_frame

	battle.set("coins", 65)
	battle.call("_update_hud")
	await process_frame

	_assert_card_affordability("orange_cat", false, "")
	_assert_card_affordability("tabby_slow_cat", true, "差 10")
	_assert_manifest_entry("battle_tower_card_insufficient_fish_stamp", SHORTAGE_STAMP_PATH)

	battle.set("coins", 75)
	battle.call("_update_hud")
	await process_frame

	_assert_card_affordability("tabby_slow_cat", false, "")

	battle.queue_free()
	_finish()


func _assert_card_affordability(tower_id: String, expected_shortage: bool, expected_label_fragment: String) -> void:
	var stamp_name: String = _shortage_stamp_name(tower_id)
	var stamp: TextureRect = _find_by_name(root, stamp_name) as TextureRect
	_assert_true(stamp != null, "%s should expose an Image2 affordability stamp node" % tower_id)
	if stamp != null:
		_assert_true(stamp.texture != null, "%s should have a stamp texture" % stamp_name)
		if stamp.texture != null:
			_assert_true(stamp.texture.resource_path == SHORTAGE_STAMP_PATH, "%s should use %s" % [stamp_name, SHORTAGE_STAMP_PATH])
		_assert_true(stamp.visible == expected_shortage, "%s visibility should match affordability state" % stamp_name)

	var label_name: String = _shortage_label_name(tower_id)
	var label: Label = _find_by_name(root, label_name) as Label
	_assert_true(label != null, "%s should expose a dynamic shortage label" % tower_id)
	if label != null:
		_assert_true(label.visible == expected_shortage, "%s visibility should match affordability state" % label_name)
		if expected_shortage:
			_assert_true(label.text.contains(expected_label_fragment), "%s should show missing fish amount" % label_name)


func _shortage_stamp_name(tower_id: String) -> String:
	return "%sInsufficientFishState" % _tower_card_container_name(tower_id)


func _shortage_label_name(tower_id: String) -> String:
	return "%sInsufficientFishLabel" % _tower_card_container_name(tower_id)


func _tower_card_container_name(tower_id: String) -> String:
	if tower_id == "orange_cat":
		return "TowerCardOrangeCat"
	if tower_id == "tabby_slow_cat":
		return "TowerCardTabbySlowCat"
	return "TowerCard%s" % tower_id.capitalize().replace("_", "")


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
		print("BATTLE TOWER AFFORDABILITY TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE TOWER AFFORDABILITY TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
