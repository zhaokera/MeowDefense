extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_shop_energy_refill_test_save.json"

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

	instance.set("_total_fish", 25)
	instance.set("_max_energy", 15)
	instance.set("_energy", 0)
	instance.set("_energy_refilled_on", "2026-06-15")
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	_assert_design_texture(
		instance,
		"ShopDesignBackground",
		"res://assets/generated/ui/shop_overlay_design_reference.png",
		"shop energy refill should keep the Image2 full-screen design"
	)
	var fish_counter: Label = _assert_label(instance, "ShopFishCounter", "shop should show fish total")
	var energy_counter: Label = _assert_label(instance, "ShopEnergyCounter", "shop should show energy total")
	var status: Label = _assert_label(instance, "ShopEnergyRefillStatus", "shop should explain the energy refill action")
	var buy_button: Button = _assert_button(instance, "BuyShopEnergyRefillButton", "shop should expose an energy refill action")
	if fish_counter != null:
		_assert_true(fish_counter.text == "25", "shop fish counter should start from current fish")
	if energy_counter != null:
		_assert_true(energy_counter.text == "0/15", "shop energy counter should start from current energy")
	if status != null:
		_assert_true(status.text.contains("10"), "energy refill status should show its fish cost")
	if buy_button != null:
		_assert_true(not buy_button.disabled, "energy refill should be enabled when affordable and not full")
		buy_button.emit_signal("pressed")
		await process_frame

	_assert_true(_int_property(instance, "_total_fish") == 15, "buying energy refill should spend 10 fish")
	_assert_true(_int_property(instance, "_energy") == 5, "buying energy refill should restore 5 energy")
	if fish_counter != null:
		_assert_true(fish_counter.text == "15", "shop fish counter should update after energy refill")
	if energy_counter != null:
		_assert_true(energy_counter.text == "5/15", "shop energy counter should update after energy refill")
	if status != null:
		_assert_true(status.text.contains("5/15"), "energy refill status should show the refreshed energy")

	instance.queue_free()
	await process_frame

	var reloaded: Node = scene.instantiate()
	reloaded.set("_save_path", TEST_SAVE_PATH)
	reloaded.set("_reward_date_override", "2026-06-15")
	root.add_child(reloaded)
	await process_frame
	_assert_true(_int_property(reloaded, "_total_fish") == 15, "fish total should persist after energy refill")
	_assert_true(_int_property(reloaded, "_energy") == 5, "energy refill should persist after reload")
	reloaded.call("_show_level_select")
	await process_frame
	var start_level: Button = _assert_button(reloaded, "StartLevel1Button", "refilled energy should allow selecting level one")
	if start_level != null:
		start_level.emit_signal("pressed")
		await process_frame
	_assert_exists(reloaded, "BattleScene", "refilled energy should allow battle entry")
	_assert_true(_int_property(reloaded, "_energy") == 4, "starting after refill should consume one energy")

	reloaded.queue_free()
	_finish()


func _int_property(instance: Node, property_name: String) -> int:
	var raw: Variant = instance.get(property_name)
	if raw == null:
		return 0
	return int(raw)


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
		print("SHOP ENERGY REFILL TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SHOP ENERGY REFILL TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear shop energy refill test save: %s" % error)
