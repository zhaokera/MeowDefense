extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_shop_purchase_overlay_guard_test_save.json"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	await _assert_energy_refill_does_not_repeat_under_reward_overlay()
	await _assert_paw_bundle_does_not_repeat_under_reward_overlay()
	await _assert_yarn_trap_does_not_repeat_under_reward_overlay()
	_finish()


func _assert_energy_refill_does_not_repeat_under_reward_overlay() -> void:
	var instance: Node = await _new_shop_instance("2026-06-21")
	if instance == null:
		return
	instance.set("_total_fish", 120)
	instance.set("_max_energy", 15)
	instance.set("_energy", 0)
	instance.set("_energy_refilled_on", "2026-06-21")
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var button: Button = _assert_button(instance, "BuyShopEnergyRefillButton", "shop should expose an energy refill purchase button")
	if button != null:
		button.emit_signal("pressed")
		await process_frame
		_assert_exists(instance, "ShopPurchaseRewardOverlay", "energy refill should show the Image2 purchase reward overlay")
		button.emit_signal("pressed")
		await process_frame
	_assert_true(_int_property(instance, "_total_fish") == 110, "energy refill should charge once while purchase reward overlay is visible")
	_assert_true(_int_property(instance, "_energy") == 5, "energy refill should restore one refill while purchase reward overlay is visible")
	_cleanup_instance(instance)


func _assert_paw_bundle_does_not_repeat_under_reward_overlay() -> void:
	var instance: Node = await _new_shop_instance("")
	if instance == null:
		return
	instance.set("_total_fish", 120)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var button: Button = _assert_button(instance, "BuyShopPawBundleButton", "shop should expose a paw bundle purchase button")
	if button != null:
		button.emit_signal("pressed")
		await process_frame
		_assert_exists(instance, "ShopPurchaseRewardOverlay", "paw bundle should show the Image2 purchase reward overlay")
		button.emit_signal("pressed")
		await process_frame
	_assert_true(_int_property(instance, "_total_fish") == 75, "paw bundle should charge once while purchase reward overlay is visible")
	_assert_true(_int_property(instance, "_paw_tokens") == 2, "paw bundle should grant one bundle while purchase reward overlay is visible")
	_cleanup_instance(instance)


func _assert_yarn_trap_does_not_repeat_under_reward_overlay() -> void:
	var instance: Node = await _new_shop_instance("")
	if instance == null:
		return
	instance.set("_total_fish", 120)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var button: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "shop should expose a yarn trap purchase button")
	if button != null:
		button.emit_signal("pressed")
		await process_frame
		_assert_exists(instance, "ShopPurchaseRewardOverlay", "yarn trap should show the Image2 purchase reward overlay")
		button.emit_signal("pressed")
		await process_frame
	_assert_true(_int_property(instance, "_total_fish") == 95, "yarn trap should charge once while purchase reward overlay is visible")
	_assert_true(_int_property(instance, "_yarn_traps") == 1, "yarn trap should grant one item while purchase reward overlay is visible")
	_cleanup_instance(instance)


func _new_shop_instance(date_key: String) -> Node:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		return null
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	if not date_key.is_empty():
		instance.set("_reward_date_override", date_key)
	root.add_child(instance)
	await process_frame
	return instance


func _cleanup_instance(instance: Node) -> void:
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	await process_frame
	_clear_save_file()


func _int_property(instance: Node, property_name: String) -> int:
	var raw: Variant = instance.get(property_name)
	if raw == null:
		return 0
	return int(raw)


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
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
		print("SHOP PURCHASE OVERLAY GUARD TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SHOP PURCHASE OVERLAY GUARD TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear shop purchase overlay guard test save: %s" % error)
