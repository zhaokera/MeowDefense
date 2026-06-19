extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const UPGRADE_SPEND_REFERENCE_PATH := "res://assets/generated/ui/tower_upgrade_spend_feedback_design_reference.png"
const UPGRADE_SPEND_SOURCE_PATH := "res://assets/generated/ui/tower_upgrade_spend_fish_chip_source.png"
const UPGRADE_SPEND_CHIP_PATH := "res://assets/generated/ui/tower_upgrade_spend_fish_chip.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_file_exists(UPGRADE_SPEND_REFERENCE_PATH, "tower upgrade spend feedback should keep an Image2 design reference")
	_assert_file_exists(UPGRADE_SPEND_SOURCE_PATH, "tower upgrade spend feedback should keep its Image2-derived source asset")
	_assert_file_exists(UPGRADE_SPEND_CHIP_PATH, "tower upgrade spend feedback should use a transparent runtime fish chip")
	_assert_manifest_entry("tower_upgrade_spend_feedback_design_reference", UPGRADE_SPEND_REFERENCE_PATH)
	_assert_manifest_entry("tower_upgrade_spend_fish_chip_source", UPGRADE_SPEND_SOURCE_PATH)
	_assert_manifest_entry("tower_upgrade_spend_fish_chip", UPGRADE_SPEND_CHIP_PATH)

	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "battle should expose the first build slot button")
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	_assert_true(int(battle.towers.size()) == 1, "test setup should build a tower")
	var tower: Node2D = battle.towers[0] as Node2D if not battle.towers.is_empty() else null
	var upgrade_cost: int = int(tower.get("upgrade_cost")) if tower != null else 0
	var coins_before_upgrade: int = int(battle.get("coins"))
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame

	var upgrade_button: Button = _assert_button(battle, "UpgradeTowerButton", "tower action panel should expose upgrade")
	if upgrade_button != null:
		upgrade_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	_assert_true(int(battle.get("coins")) == coins_before_upgrade - upgrade_cost, "upgrade should spend its fish cost")
	var chip: TextureRect = _assert_texture_node(
		battle,
		"TowerUpgradeSpendFish1",
		UPGRADE_SPEND_CHIP_PATH,
		"successful tower upgrade should create an Image2 fish-spend chip flying from the counter to the tower"
	)
	if chip != null:
		_assert_true(bool(chip.get_meta("image2_tower_upgrade_spend_feedback", false)), "upgrade spend chip should mark Image2 feedback metadata")
		_assert_true(int(chip.get_meta("cost", 0)) == upgrade_cost, "upgrade spend chip should remember the upgrade cost")
		_assert_true(chip.mouse_filter == Control.MOUSE_FILTER_IGNORE, "upgrade spend chip should not block battle input")
	var spend_label: Label = _assert_label(battle, "TowerUpgradeSpendAmountLabel", "upgrade spend chip should include a dynamic cost label")
	if spend_label != null:
		_assert_true(spend_label.text.contains("-%d" % upgrade_cost), "upgrade spend label should show the deducted fish amount")
	var coins_label: Label = _assert_label(battle, "CoinsLabel", "battle should keep the top fish counter")
	if coins_label != null:
		_assert_true(bool(coins_label.get_meta("image2_tower_upgrade_spend_source", false)), "fish counter should be marked as the upgrade spend source")
		_assert_true(coins_label.text.contains(str(coins_before_upgrade - upgrade_cost)), "fish counter should show the post-upgrade total")

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
		print("TOWER UPGRADE SPEND FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("TOWER UPGRADE SPEND FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
