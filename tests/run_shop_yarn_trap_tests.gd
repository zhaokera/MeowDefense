extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_shop_yarn_trap_test_save.json"

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
	root.add_child(instance)
	await process_frame

	instance.set("_total_fish", 40)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	_assert_design_texture(
		instance,
		"ShopDesignBackground",
		"res://assets/generated/ui/shop_overlay_design_reference.png",
		"shop should keep the Image2 full-screen design"
	)
	_assert_design_texture(
		instance,
		"ShopYarnTrapIcon",
		"res://assets/generated/ui/yarn_trap_item_icon.png",
		"yarn trap product should use an Image2 item icon"
	)
	var fish_counter: Label = _assert_label(instance, "ShopFishCounter", "shop should show fish total")
	var status: Label = _assert_label(instance, "ShopYarnTrapKitStatus", "yarn trap product should show purchase state")
	var buy_button: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "yarn trap product should expose a buy button")
	if fish_counter != null:
		_assert_true(fish_counter.text == "40", "shop fish counter should start from current fish")
	if status != null:
		_assert_true(status.text.contains("25"), "yarn trap status should show its fish cost")
	if buy_button != null:
		_assert_true(not buy_button.disabled, "yarn trap buy button should be enabled when affordable")
		buy_button.emit_signal("pressed")
		await process_frame

	_assert_true(_int_property(instance, "_total_fish") == 15, "buying yarn trap should spend 25 fish")
	_assert_true(_int_property(instance, "_yarn_traps") == 1, "buying yarn trap should add one backpack item")
	if fish_counter != null:
		_assert_true(fish_counter.text == "15", "shop fish counter should update after yarn trap purchase")
	if status != null:
		_assert_true(status.text.contains("已购买") or status.text.contains("持有"), "yarn trap status should update after purchase")

	var close_shop: Button = _assert_button(instance, "CloseShopButton", "shop should be closable")
	if close_shop != null:
		close_shop.emit_signal("pressed")
		await process_frame
	var bag_button: Button = _assert_button(instance, "BottomBagButton", "main menu should expose backpack")
	if bag_button != null:
		bag_button.emit_signal("pressed")
		await process_frame
	var trap_detail: Label = _assert_label(instance, "BackpackYarnTrapItemDetail", "backpack should show yarn trap count")
	if trap_detail != null:
		_assert_true(trap_detail.text.contains("1"), "backpack yarn trap detail should reflect purchased item")

	instance.queue_free()
	await process_frame

	var reloaded: Node = scene.instantiate()
	reloaded.set("_save_path", TEST_SAVE_PATH)
	root.add_child(reloaded)
	await process_frame
	_assert_true(_int_property(reloaded, "_total_fish") == 15, "fish total should persist after yarn trap purchase")
	_assert_true(_int_property(reloaded, "_yarn_traps") == 1, "yarn trap count should persist after reload")
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
		print("SHOP YARN TRAP TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SHOP YARN TRAP TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear shop yarn trap test save: %s" % error)
