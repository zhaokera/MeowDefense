extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const SELL_REFUND_REFERENCE_PATH := "res://assets/generated/ui/tower_sell_refund_fly_feedback_design_reference.png"
const SELL_REFUND_SOURCE_PATH := "res://assets/generated/ui/tower_sell_refund_fish_chip_source.png"
const SELL_REFUND_CHIP_PATH := "res://assets/generated/ui/tower_sell_refund_fish_chip.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_file_exists(SELL_REFUND_REFERENCE_PATH, "tower sell refund fly feedback should keep an Image2 design reference")
	_assert_file_exists(SELL_REFUND_SOURCE_PATH, "tower sell refund fly feedback should keep its Image2-derived source asset")
	_assert_file_exists(SELL_REFUND_CHIP_PATH, "tower sell refund fly feedback should use a transparent runtime fish chip")
	_assert_manifest_entry("tower_sell_refund_fly_feedback_design_reference", SELL_REFUND_REFERENCE_PATH)
	_assert_manifest_entry("tower_sell_refund_fish_chip_source", SELL_REFUND_SOURCE_PATH)
	_assert_manifest_entry("tower_sell_refund_fish_chip", SELL_REFUND_CHIP_PATH)

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
	var coins_after_build: int = int(battle.get("coins"))
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame

	var sell_button: Button = _assert_button(battle, "SellTowerButton", "tower action panel should expose sell")
	if sell_button != null:
		sell_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	var refund: int = int(battle.get("coins")) - coins_after_build
	_assert_true(refund > 0, "selling should refund fish")
	var chip: TextureRect = _assert_texture_node(
		battle,
		"TowerSellRefundFlyFish1",
		SELL_REFUND_CHIP_PATH,
		"successful tower sell should create an Image2 refund chip flying to the fish counter"
	)
	if chip != null:
		_assert_true(bool(chip.get_meta("image2_tower_sell_refund_fly_feedback", false)), "sell refund fly chip should mark Image2 feedback metadata")
		_assert_true(int(chip.get_meta("refund", 0)) == refund, "sell refund fly chip should remember the refund amount")
		_assert_true(chip.mouse_filter == Control.MOUSE_FILTER_IGNORE, "sell refund fly chip should not block battle input")
	var refund_label: Label = _assert_label(battle, "TowerSellRefundFlyAmountLabel", "sell refund fly chip should include dynamic refund text")
	if refund_label != null:
		_assert_true(refund_label.text.contains("+%d" % refund), "sell refund fly label should show the refunded fish amount")
	var coins_label: Label = _assert_label(battle, "CoinsLabel", "battle should keep the top fish counter")
	if coins_label != null:
		_assert_true(bool(coins_label.get_meta("image2_tower_sell_refund_target", false)), "fish counter should be marked as the sell refund target")
		_assert_true(coins_label.text.contains(str(coins_after_build + refund)), "fish counter should show the post-sell total")

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
		print("TOWER SELL REFUND FLY FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("TOWER SELL REFUND FLY FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
