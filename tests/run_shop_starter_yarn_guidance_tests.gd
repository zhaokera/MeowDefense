extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_shop_starter_yarn_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/shop_starter_yarn_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/shop_starter_yarn_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/shop_starter_yarn_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "starter fish pack should keep an Image2 full-screen yarn guidance reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "starter fish pack should keep an Image2-derived yarn guidance source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "starter fish pack should use a transparent runtime yarn guidance badge")
	_assert_manifest_entry("shop_starter_yarn_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("shop_starter_yarn_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("shop_starter_yarn_guidance_badge", GUIDANCE_BADGE_PATH)

	await _assert_non_starter_purchase_does_not_show_starter_yarn_guidance()
	await _assert_starter_pack_refreshes_yarn_purchase_and_guides_to_it()
	_finish()


func _assert_non_starter_purchase_does_not_show_starter_yarn_guidance() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_shop_starter_claimed", true)
	instance.set("_total_fish", 60)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var paw_button: Button = _assert_button(instance, "BuyShopPawBundleButton", "paw purchase guard should expose paw buy button")
	if paw_button != null:
		paw_button.emit_signal("pressed")
		await process_frame
		await process_frame
	_assert_exists(instance, "ShopPurchaseRewardOverlay", "paw purchase should still show reward overlay")
	_assert_missing(instance, "ShopStarterYarnGuidance", "non-starter purchases should not show starter yarn guidance")
	_cleanup_instance(instance)


func _assert_starter_pack_refreshes_yarn_purchase_and_guides_to_it() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_total_fish", 10)
	instance.set("_shop_starter_claimed", false)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var yarn_before: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "starter path should expose yarn buy button")
	if yarn_before != null:
		_assert_true(yarn_before.disabled, "yarn purchase should begin disabled with only 10 fish")
	_assert_exists(instance, "ShopYarnTrapKitShortageButton", "insufficient yarn purchase should expose shortage route before starter fish")
	_assert_exists(instance, "ShopYarnTrapKitInsufficientStamp", "insufficient yarn purchase should show the Image2 shortage stamp before starter fish")

	var starter_claim: Button = _assert_button(instance, "ClaimShopFishPackButton", "starter fish pack should expose claim button")
	if starter_claim != null:
		starter_claim.emit_signal("pressed")
		await process_frame
		await process_frame

	_assert_true(int(instance.get("_total_fish")) == 25, "starter fish pack should raise total fish to yarn price")
	var reward: Control = _assert_control(instance, "ShopPurchaseRewardOverlay", "starter fish claim should show purchase reward overlay")
	var guidance: Control = _assert_control(instance, "ShopStarterYarnGuidance", "starter fish claim should show yarn purchase guidance when yarn becomes affordable")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_shop_starter_yarn_guidance", false)), "starter yarn guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "starter yarn guidance group should not block its route button")
	var badge: TextureRect = _assert_texture_node(instance, "ShopStarterYarnBadge", GUIDANCE_BADGE_PATH, "starter yarn guidance should show the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "starter yarn guidance badge should not block route button")
	var label: Label = _assert_label(instance, "ShopStarterYarnLabel", "starter yarn guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("毛线") or label.text.contains("购买"), "starter yarn guidance should point to buying yarn")

	var yarn_after: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "starter fish should keep yarn buy button in shop")
	if yarn_after != null:
		_assert_true(not yarn_after.disabled, "starter fish should immediately enable yarn purchase")
		_assert_true(bool(yarn_after.get_meta("image2_shop_starter_yarn_target", false)), "starter fish should mark yarn buy button as the guided target")
	_assert_missing(instance, "ShopYarnTrapKitShortageButton", "starter fish should remove the old yarn shortage route")
	_assert_missing(instance, "ShopYarnTrapKitInsufficientStamp", "starter fish should remove the old yarn shortage stamp")
	var buy_frame: TextureRect = _assert_texture_node(instance, "ShopYarnTrapKitBuyButtonFrame", "res://assets/generated/ui/shop_product_buy_button_plate.png", "starter fish should replace shortage stamp with the Image2 buy plate")
	if buy_frame != null:
		_assert_true(bool(buy_frame.get_meta("image2_shop_starter_yarn_target", false)), "starter fish should mark yarn buy plate as the guided target")

	var route_button: Button = _assert_button(instance, "ShopStarterYarnButton", "starter yarn guidance should expose a yarn route button")
	if reward != null and route_button != null:
		route_button.emit_signal("pressed")
		_assert_true(bool(reward.get_meta("image2_overlay_exit_animation", false)), "starter yarn route should animate the Image2 reward overlay out")
		_assert_true(route_button.disabled, "starter yarn route should disable while routing")
		await _wait_until_missing(instance, "ShopPurchaseRewardOverlay")

	var buy_ready: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "yarn buy button should remain after starter guidance closes")
	if buy_ready != null:
		_assert_true(not buy_ready.disabled, "yarn purchase should remain enabled after starter guidance closes")
		buy_ready.emit_signal("pressed")
		await process_frame
		await process_frame
	_assert_true(int(instance.get("_total_fish")) == 0, "buying yarn after starter guidance should spend the 25 fish")
	_assert_true(int(instance.get("_yarn_traps")) == 1, "buying yarn after starter guidance should add one yarn trap")
	_assert_exists(instance, "ShopYarnPurchaseBackpackGuidance", "buying yarn after starter guidance should still show backpack guidance")
	_cleanup_instance(instance)


func _new_instance() -> Node:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		return null
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


func _wait_until_missing(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) == null:
			return
		await process_frame


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("SHOP STARTER YARN GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SHOP STARTER YARN GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear shop starter yarn guidance test save: %s" % error)
