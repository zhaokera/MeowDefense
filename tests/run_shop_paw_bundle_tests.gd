extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_shop_paw_bundle_test_save.json"

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

	instance.set("_total_fish", 80)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	_assert_design_texture(
		instance,
		"ShopPawBundleIcon",
		"res://assets/generated/ui/album_paw_badge.png",
		"paw bundle product should use an Image2 paw badge asset"
	)
	var fish_counter: Label = _assert_label(instance, "ShopFishCounter", "shop should show fish total")
	var status: Label = _assert_label(instance, "ShopPawBundleStatus", "paw bundle product should show purchase state")
	var buy_button: Button = _assert_button(instance, "BuyShopPawBundleButton", "paw bundle product should expose a buy button")
	if fish_counter != null:
		_assert_true(fish_counter.text == "80", "shop fish counter should start from current fish")
	if status != null:
		_assert_true(status.text.contains("45"), "paw bundle status should show its fish cost")
	if buy_button != null:
		_assert_true(not buy_button.disabled, "paw bundle buy button should be enabled when affordable")
		buy_button.emit_signal("pressed")
		await process_frame

	_assert_true(_int_property(instance, "_total_fish") == 35, "buying paw bundle should spend 45 fish")
	_assert_true(_int_property(instance, "_paw_tokens") == 2, "buying paw bundle should add two paw tokens")
	if fish_counter != null:
		_assert_true(fish_counter.text == "35", "shop fish counter should update after paw bundle purchase")
	if status != null:
		_assert_true(status.text.contains("持有2") or status.text.contains("已购买"), "paw bundle status should update after purchase")

	var close_shop: Button = _assert_button(instance, "CloseShopButton", "shop should be closable")
	if close_shop != null:
		close_shop.emit_signal("pressed")
		await process_frame
	var bag_button: Button = _assert_button(instance, "BottomBagButton", "main menu should expose backpack")
	if bag_button != null:
		bag_button.emit_signal("pressed")
		await process_frame
	var paw_detail: Label = _assert_label(instance, "BackpackPawTokenItemDetail", "backpack should show paw token count")
	if paw_detail != null:
		_assert_true(paw_detail.text.contains("2"), "backpack paw token detail should reflect purchased bundle")

	instance.queue_free()
	await process_frame

	var reloaded: Node = scene.instantiate()
	reloaded.set("_save_path", TEST_SAVE_PATH)
	root.add_child(reloaded)
	await process_frame
	_assert_true(_int_property(reloaded, "_total_fish") == 35, "fish total should persist after paw bundle purchase")
	_assert_true(_int_property(reloaded, "_paw_tokens") == 2, "paw bundle tokens should persist after reload")
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
		print("SHOP PAW BUNDLE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SHOP PAW BUNDLE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear paw bundle test save: %s" % error)
