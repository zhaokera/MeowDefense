extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_shop_product_state_asset_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const PRODUCT_STATE_DESIGN_PATH := "res://assets/generated/ui/shop_product_state_design_reference.png"
const BUY_BUTTON_PATH := "res://assets/generated/ui/shop_product_buy_button_plate.png"
const INSUFFICIENT_STAMP_PATH := "res://assets/generated/ui/shop_product_insufficient_fish_stamp.png"
const ENERGY_BUTTON_PATH := "res://assets/generated/ui/shop_energy_refill_button_plate.png"

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
	instance.set("_total_fish", 90)
	instance.set("_energy", 8)

	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	_assert_texture(instance, "ShopPawBundleBuyButtonFrame", BUY_BUTTON_PATH, "paw bundle should use an Image2 buy-button plate")
	_assert_texture(instance, "ShopYarnTrapKitBuyButtonFrame", BUY_BUTTON_PATH, "yarn trap should use an Image2 buy-button plate")
	_assert_texture(instance, "ShopEnergyRefillButtonFrame", ENERGY_BUTTON_PATH, "energy refill should use an Image2 plus button plate")
	_assert_missing(instance, "ShopPawBundleInsufficientStamp", "affordable paw bundle should not show insufficient stamp")
	_assert_missing(instance, "ShopYarnTrapKitInsufficientStamp", "affordable yarn trap should not show insufficient stamp")

	var paw_buy: Button = _assert_button(instance, "BuyShopPawBundleButton", "paw bundle buy hit area should still exist")
	if paw_buy != null:
		_assert_true(paw_buy.text.contains("购买"), "paw bundle should keep dynamic purchase text over the Image2 button plate")
		_assert_true(not paw_buy.disabled, "paw bundle should be buyable when fish is sufficient")
	var yarn_buy: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "yarn trap buy hit area should still exist")
	if yarn_buy != null:
		_assert_true(yarn_buy.text.contains("购买"), "yarn trap should keep dynamic purchase text over the Image2 button plate")
		_assert_true(not yarn_buy.disabled, "yarn trap should be buyable when fish is sufficient")

	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	instance.set("_total_fish", 0)
	instance.set("_energy", 0)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	_assert_texture(instance, "ShopPawBundleInsufficientStamp", INSUFFICIENT_STAMP_PATH, "paw bundle should show an Image2 insufficient-fish stamp")
	_assert_texture(instance, "ShopYarnTrapKitInsufficientStamp", INSUFFICIENT_STAMP_PATH, "yarn trap should show an Image2 insufficient-fish stamp")
	_assert_texture(instance, "ShopEnergyRefillInsufficientStamp", INSUFFICIENT_STAMP_PATH, "energy refill should show an Image2 insufficient-fish stamp")
	var paw_shortage: Button = _assert_button(instance, "ShopPawBundleShortageButton", "paw bundle shortage hit area should remain tappable")
	if paw_shortage != null:
		paw_shortage.emit_signal("pressed")
		await process_frame
		_assert_exists(instance, "ShopInsufficientFishOverlay", "insufficient stamp state should still route to shortage feedback")

	_assert_manifest_entry("shop_product_state_design_reference", PRODUCT_STATE_DESIGN_PATH)
	_assert_manifest_entry("shop_product_buy_button_plate", BUY_BUTTON_PATH)
	_assert_manifest_entry("shop_product_insufficient_fish_stamp", INSUFFICIENT_STAMP_PATH)
	_assert_manifest_entry("shop_energy_refill_button_plate", ENERGY_BUTTON_PATH)

	instance.queue_free()
	_finish()


func _assert_texture(root_node: Node, node_name: String, expected_path: String, message: String) -> TextureRect:
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


func _assert_exists(root_node: Node, node_name: String, message: String) -> Node:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
	return node


func _assert_missing(root_node: Node, node_name: String, message: String) -> void:
	if _find_by_name(root_node, node_name) != null:
		_failures.append(message)


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
		print("SHOP PRODUCT STATE ASSET TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SHOP PRODUCT STATE ASSET TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear shop product state asset test save: %s" % error)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
