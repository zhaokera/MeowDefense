extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish()
		return

	var instance: Node = scene.instantiate()
	if instance == null:
		_failures.append("main scene should instantiate")
		_finish()
		return

	root.add_child(instance)
	await process_frame

	_assert_exists(instance, "MainMenuScreen", "main menu should render first")
	await _assert_main_menu_backpack(instance)
	await _assert_main_menu_achievements(instance)
	await _assert_main_menu_shop(instance)
	await _assert_level_select_shop(instance)

	instance.queue_free()
	_finish()


func _assert_main_menu_backpack(instance: Node) -> void:
	var bag_button: Button = _assert_button(instance, "BottomBagButton", "main menu should expose backpack")
	if bag_button == null:
		return
	bag_button.emit_signal("pressed")
	await process_frame
	_assert_exists(instance, "BackpackOverlay", "backpack button should open the backpack overlay")
	_assert_design_texture(instance, "BackpackDesignBackground", "res://assets/generated/ui/backpack_overlay_design_reference.png", "backpack should render from its Image2 full-screen design")
	_assert_missing(instance, "RewardOverlay", "backpack should not reuse the daily reward overlay")
	var close_button: Button = _assert_button(instance, "CloseBackpackButton", "backpack should be closable")
	if close_button != null:
		close_button.emit_signal("pressed")
		await process_frame
		_assert_missing(instance, "BackpackOverlay", "backpack should close")


func _assert_main_menu_achievements(instance: Node) -> void:
	var achievements_button: Button = _assert_button(instance, "BottomAchievementsButton", "main menu should expose achievements")
	if achievements_button == null:
		return
	achievements_button.emit_signal("pressed")
	await process_frame
	_assert_exists(instance, "AchievementsOverlay", "achievements button should open the achievements overlay")
	_assert_design_texture(instance, "AchievementsDesignBackground", "res://assets/generated/ui/achievements_overlay_design_reference.png", "achievements should render from its Image2 full-screen design")
	_assert_missing(instance, "AlbumOverlay", "achievements should not reuse the guide album overlay")
	var close_button: Button = _assert_button(instance, "CloseAchievementsButton", "achievements should be closable")
	if close_button != null:
		close_button.emit_signal("pressed")
		await process_frame
		_assert_missing(instance, "AchievementsOverlay", "achievements should close")


func _assert_main_menu_shop(instance: Node) -> void:
	var shop_button: Button = _assert_button(instance, "BottomShopButton", "main menu should expose shop")
	if shop_button == null:
		return
	shop_button.emit_signal("pressed")
	await process_frame
	_assert_exists(instance, "ShopOverlay", "shop button should open the shop overlay")
	_assert_design_texture(instance, "ShopDesignBackground", "res://assets/generated/ui/shop_overlay_design_reference.png", "shop should render from its Image2 full-screen design")
	_assert_missing(instance, "RewardOverlay", "shop should not reuse the daily reward overlay")
	var fish_counter: Label = _assert_label(instance, "ShopFishCounter", "shop should show the current fish total")
	var claim_button: Button = _assert_button(instance, "ClaimShopFishPackButton", "shop should expose a fish-pack claim action")
	if fish_counter != null and claim_button != null:
		_assert_true(fish_counter.text == "0", "shop should start from the current fish total")
		claim_button.emit_signal("pressed")
		await process_frame
		_assert_true(fish_counter.text == "15", "shop fish-pack claim should grant starter fish")
	var close_button: Button = _assert_button(instance, "CloseShopButton", "shop should be closable")
	if close_button != null:
		close_button.emit_signal("pressed")
		await process_frame
		_assert_missing(instance, "ShopOverlay", "shop should close")
		shop_button.emit_signal("pressed")
		await process_frame
		var claim_status: Label = _assert_label(instance, "ShopClaimStatus", "shop should remember claimed starter pack")
		if claim_status != null:
			_assert_true(claim_status.text == "已领取", "shop starter pack should only be claimed once")


func _assert_level_select_shop(instance: Node) -> void:
	var start_button: Button = _assert_button(instance, "StartLevelSelectButton", "main menu should expose start")
	if start_button == null:
		return
	start_button.emit_signal("pressed")
	await process_frame
	_assert_exists(instance, "LevelSelectScreen", "start should show level select")
	var shop_button: Button = _assert_button(instance, "BottomShopButton", "level select should expose shop")
	if shop_button == null:
		return
	shop_button.emit_signal("pressed")
	await process_frame
	_assert_exists(instance, "ShopOverlay", "level select shop should open the shop overlay")
	_assert_design_texture(instance, "ShopDesignBackground", "res://assets/generated/ui/shop_overlay_design_reference.png", "level select shop should render from its Image2 full-screen design")


func _finish() -> void:
	if _failures.is_empty():
		print("TOWN FEATURE OVERLAY TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("TOWN FEATURE OVERLAY TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_exists(root_node: Node, node_name: String, message: String) -> Node:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
	return node


func _assert_missing(root_node: Node, node_name: String, message: String) -> void:
	if _find_by_name(root_node, node_name) != null:
		_failures.append(message)


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


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _assert_design_texture(root_node: Node, node_name: String, expected_path: String, message: String) -> void:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return
	if not node is TextureRect:
		_failures.append("%s should be a TextureRect" % node_name)
		return
	var rect: TextureRect = node as TextureRect
	if rect.texture == null:
		_failures.append("%s should have a texture" % node_name)
		return
	if rect.texture.resource_path != expected_path:
		_failures.append("%s should use %s" % [node_name, expected_path])


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null
