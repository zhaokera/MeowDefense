extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_shop_buyable_design_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const SHOP_BUYABLE_DESIGN_PATH := "res://assets/generated/ui/shop_overlay_buyable_design_reference.png"

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
		"ShopDesignBackground",
		SHOP_BUYABLE_DESIGN_PATH,
		"shop should use the Image2 buyable-product design instead of the old locked-product design"
	)
	_assert_missing(instance, "ShopTitle", "shop title should come from the Image2 design, not a duplicate runtime label")
	_assert_missing(instance, "ShopFishPackTitle", "fish pack title should come from the Image2 design, not a duplicate runtime label")
	_assert_missing(instance, "ShopPawBundleTitle", "paw bundle title should come from the Image2 design, not a duplicate runtime label")
	_assert_missing(instance, "ShopYarnTrapKitTitle", "yarn trap title should come from the Image2 design, not a duplicate runtime label")
	_assert_missing(instance, "ShopPawBundleIcon", "paw bundle art should come from the Image2 design, not a duplicate runtime icon")
	_assert_missing(instance, "ShopYarnTrapIcon", "yarn trap art should come from the Image2 design, not a duplicate runtime icon")
	var claim_button: Button = _assert_button(instance, "ClaimShopFishPackButton", "fish pack should expose a claim button")
	if claim_button != null:
		_assert_true(claim_button.position.y <= 520.0, "fish pack claim text should sit on the Image2 button plate")
	var paw_button: Button = _assert_button(instance, "BuyShopPawBundleButton", "paw bundle should expose a buy button")
	if paw_button != null:
		_assert_true(not paw_button.disabled, "paw bundle buy button should be enabled when affordable")
		_assert_true(not paw_button.text.contains("未开放"), "paw bundle should not present as unopened content")
		_assert_true(paw_button.text.contains("购买"), "paw bundle should present a purchase action")
		_assert_true(paw_button.position.y <= 520.0, "paw bundle buy text should sit on the Image2 button plate")
	var yarn_button: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "yarn trap kit should expose a buy button")
	if yarn_button != null:
		_assert_true(not yarn_button.disabled, "yarn trap kit buy button should be enabled when affordable")
		_assert_true(not yarn_button.text.contains("未开放"), "yarn trap kit should not present as unopened content")
		_assert_true(yarn_button.text.contains("购买"), "yarn trap kit should present a purchase action")
		_assert_true(yarn_button.position.y <= 520.0, "yarn trap buy text should sit on the Image2 button plate")
	_assert_manifest_entry("shop_overlay_buyable_design_reference", SHOP_BUYABLE_DESIGN_PATH)

	instance.queue_free()
	_finish()


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
		print("SHOP BUYABLE DESIGN TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SHOP BUYABLE DESIGN TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear shop buyable design test save: %s" % error)
