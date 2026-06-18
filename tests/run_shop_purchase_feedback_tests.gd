extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_shop_purchase_feedback_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const SHOP_PURCHASE_FEEDBACK_DESIGN_PATH := "res://assets/generated/ui/shop_purchase_feedback_design_reference.png"
const SHOP_PURCHASE_REWARD_BURST_PATH := "res://assets/generated/ui/shop_purchase_reward_burst.png"
const SHOP_PURCHASE_REWARD_BURST_SOURCE_PATH := "res://assets/generated/ui/shop_purchase_reward_burst_source.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish()
		return

	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	instance.set("_reward_date_override", "2026-06-15")
	root.add_child(instance)
	await process_frame

	instance.set("_total_fish", 110)
	instance.set("_max_energy", 15)
	instance.set("_energy", 0)
	instance.set("_energy_refilled_on", "2026-06-15")
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	await _assert_purchase_feedback(instance, "ClaimShopFishPackButton", "小鱼干补给", "小鱼干 +15")
	await _assert_purchase_feedback(instance, "BuyShopPawBundleButton", "猫爪徽章包", "徽章 +2")
	await _assert_purchase_feedback(instance, "BuyShopYarnTrapKitButton", "毛线陷阱", "毛线陷阱 +1")
	await _assert_purchase_feedback(instance, "BuyShopEnergyRefillButton", "体力补充", "体力 +5")

	_assert_manifest_entry("shop_purchase_feedback_design_reference", SHOP_PURCHASE_FEEDBACK_DESIGN_PATH)
	_assert_manifest_entry("shop_purchase_reward_burst_source", SHOP_PURCHASE_REWARD_BURST_SOURCE_PATH)
	_assert_manifest_entry("shop_purchase_reward_burst", SHOP_PURCHASE_REWARD_BURST_PATH)

	instance.queue_free()
	_finish()


func _assert_purchase_feedback(instance: Node, button_name: String, expected_title: String, expected_amount: String) -> void:
	var button: Button = _assert_button(instance, button_name, "%s should be available for purchase feedback testing" % button_name)
	if button == null:
		return
	_assert_true(not button.disabled, "%s should be enabled before purchase" % button_name)
	button.emit_signal("pressed")
	await process_frame
	await process_frame

	_assert_exists(instance, "ShopPurchaseRewardOverlay", "%s should open a shop purchase reward overlay" % button_name)
	_assert_design_texture(
		instance,
		"ShopPurchaseRewardDesignBackground",
		SHOP_PURCHASE_FEEDBACK_DESIGN_PATH,
		"shop purchase feedback should render from its Image2 full-screen design"
	)
	_assert_design_texture(
		instance,
		"ShopPurchaseRewardBurst",
		SHOP_PURCHASE_REWARD_BURST_PATH,
		"shop purchase feedback should include the Image2 reward burst"
	)
	var title: Label = _assert_label(instance, "ShopPurchaseRewardTitle", "shop purchase feedback should show a purchase title")
	if title != null:
		_assert_true(title.text.contains(expected_title), "%s feedback title should mention %s" % [button_name, expected_title])
	var amount: Label = _assert_label(instance, "ShopPurchaseRewardAmount", "shop purchase feedback should show a reward amount")
	if amount != null:
		_assert_true(amount.text.contains(expected_amount), "%s feedback amount should mention %s" % [button_name, expected_amount])
	var close_button: Button = _assert_button(instance, "CloseShopPurchaseRewardButton", "shop purchase feedback should be closable")
	if close_button != null:
		close_button.emit_signal("pressed")
		for i: int in range(45):
			await process_frame
		_assert_missing(instance, "ShopPurchaseRewardOverlay", "closed shop purchase feedback should be removed")


func _assert_manifest_entry(id: String, expected_path: String) -> void:
	var manifest_file: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if manifest_file == null:
		_failures.append("asset manifest should be readable")
		return
	var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
	if not (parsed is Dictionary):
		_failures.append("asset manifest should parse as a dictionary")
		return
	var ui_items: Array = (parsed as Dictionary).get("ui", []) as Array
	for item: Variant in ui_items:
		if not (item is Dictionary):
			continue
		var entry: Dictionary = item as Dictionary
		if str(entry.get("id", "")) == id:
			_assert_true(str(entry.get("path", "")) == expected_path, "%s should point to %s" % [id, expected_path])
			return
	_failures.append("asset manifest should include %s" % id)


func _assert_design_texture(root_node: Node, node_name: String, expected_path: String, message: String) -> void:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return
	if not node is TextureRect:
		_failures.append("%s should be a TextureRect" % node_name)
		return
	var rect: TextureRect = node as TextureRect
	_assert_true(rect.texture != null, "%s should have a texture" % node_name)
	if rect.texture != null:
		_assert_true(rect.texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])


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
	_clear_save_file()
	if _failures.is_empty():
		print("SHOP PURCHASE FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SHOP PURCHASE FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear shop purchase feedback test save: %s" % error)
