extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_shop_yarn_purchase_backpack_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/shop_yarn_purchase_backpack_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/shop_yarn_purchase_backpack_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/shop_yarn_purchase_backpack_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "shop yarn purchase should keep an Image2 full-screen purchase guidance reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "shop yarn purchase should keep an Image2-derived guidance source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "shop yarn purchase should use a transparent runtime guidance badge")
	_assert_manifest_entry("shop_yarn_purchase_backpack_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("shop_yarn_purchase_backpack_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("shop_yarn_purchase_backpack_guidance_badge", GUIDANCE_BADGE_PATH)

	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish()
		return

	var paw_instance: Node = await _new_instance(scene)
	if paw_instance != null:
		paw_instance.set("_total_fish", 60)
		paw_instance.call("_show_shop_overlay", paw_instance.find_child("MainMenuScreen", true, false))
		await process_frame
		var paw_button: Button = _assert_button(paw_instance, "BuyShopPawBundleButton", "paw bundle should be purchasable for non-yarn guidance guard")
		if paw_button != null:
			paw_button.emit_signal("pressed")
			await process_frame
		_assert_exists(paw_instance, "ShopPurchaseRewardOverlay", "paw purchase should still show purchase reward")
		_assert_missing(paw_instance, "ShopYarnPurchaseBackpackGuidance", "paw purchase should not show yarn backpack guidance")
		_cleanup_instance(paw_instance)

	var instance: Node = await _new_instance(scene)
	if instance == null:
		_finish()
		return
	instance.set("_total_fish", 40)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var buy_button: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "yarn trap should expose a buy button")
	if buy_button != null:
		buy_button.emit_signal("pressed")
		await process_frame
		await process_frame

	_assert_true(int(instance.get("_total_fish")) == 15, "buying yarn trap should spend fish before guidance")
	_assert_true(int(instance.get("_yarn_traps")) == 1, "buying yarn trap should add inventory before guidance")
	var overlay: Control = _assert_control(instance, "ShopPurchaseRewardOverlay", "yarn purchase should open purchase reward overlay")
	var guidance: Control = _assert_control(instance, "ShopYarnPurchaseBackpackGuidance", "yarn purchase should show backpack guidance")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_shop_yarn_purchase_backpack_guidance", false)), "yarn purchase backpack guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "yarn purchase guidance group should not block its route button")
	var badge: TextureRect = _assert_texture_node(instance, "ShopYarnPurchaseBackpackBadge", GUIDANCE_BADGE_PATH, "yarn purchase guidance should show the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "yarn purchase guidance badge should not block route button")
	var label: Label = _assert_label(instance, "ShopYarnPurchaseBackpackLabel", "yarn purchase guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("背包") or label.text.contains("毛线"), "yarn purchase guidance should point to backpack usage")
	var route_button: Button = _assert_button(instance, "ShopYarnPurchaseBackpackButton", "yarn purchase guidance should expose a backpack route button")
	if overlay != null and route_button != null:
		route_button.emit_signal("pressed")
		_assert_true(bool(overlay.get_meta("image2_overlay_exit_animation", false)), "yarn purchase backpack route should animate the Image2 purchase overlay out")
		_assert_true(route_button.disabled, "yarn purchase backpack route should disable while routing")
		_assert_missing(instance, "BackpackOverlay", "yarn purchase backpack route should not hard-cut before purchase exit")
		await _wait_until_missing(instance, "ShopPurchaseRewardOverlay")
		await _wait_until_exists(instance, "BackpackOverlay")

	_assert_exists(instance, "BackpackOverlay", "yarn purchase backpack route should open backpack")
	var trap_detail: Label = _assert_label(instance, "BackpackYarnTrapItemDetail", "backpack should show purchased yarn trap count")
	if trap_detail != null:
		_assert_true(trap_detail.text.contains("1"), "backpack yarn trap detail should reflect purchased item")
	_assert_true(int(instance.get("_yarn_traps")) == 1, "routing to backpack should not consume yarn traps")

	_cleanup_instance(instance)
	_finish()


func _new_instance(scene: PackedScene) -> Node:
	_clear_save_file()
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame
	return instance


func _cleanup_instance(instance: Node) -> void:
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	await process_frame
	_clear_save_file()


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


func _assert_control(root_node: Node, node_name: String, message: String) -> Control:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Control:
		return node as Control
	_failures.append("%s should be a Control" % node_name)
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
	if node == null:
		return null
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) != null:
			return
		await process_frame


func _wait_until_missing(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) == null:
			return
		await process_frame


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("SHOP YARN PURCHASE BACKPACK GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SHOP YARN PURCHASE BACKPACK GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear shop yarn purchase backpack guidance test save: %s" % error)
