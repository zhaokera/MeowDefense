extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_daily_task_shop_return_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/daily_task_shop_return_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/daily_task_shop_return_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/daily_task_shop_return_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "daily task shop-return should keep an Image2 full-screen reward guidance reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "daily task shop-return should keep an Image2-derived guidance source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "daily task shop-return should use a transparent runtime guidance badge")
	_assert_manifest_entry("daily_task_shop_return_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("daily_task_shop_return_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("daily_task_shop_return_guidance_badge", GUIDANCE_BADGE_PATH)

	var normal: Node = await _new_instance()
	if normal != null:
		normal.set("_best_stars_by_level", {1: 3})
		normal.call("_recalculate_best_stars")
		var task_button: Button = _assert_button(normal, "DailyTaskButton", "normal path should expose daily task entry")
		if task_button != null:
			task_button.emit_signal("pressed")
			await process_frame
		var normal_claim: Button = _assert_button(normal, "ClaimDailyTaskFirstClearButton", "normal path should expose first-clear claim")
		if normal_claim != null:
			normal_claim.emit_signal("pressed")
			await process_frame
			await process_frame
		_assert_exists(normal, "DailyTaskClaimRewardOverlay", "normal daily task claim should still show reward overlay")
		_assert_missing(normal, "DailyTaskShopReturnGuidance", "normal daily task claims should not show shop-return guidance")
		_cleanup_instance(normal)

	var instance: Node = await _new_instance()
	if instance == null:
		_finish()
		return
	instance.set("_shop_starter_claimed", true)
	instance.set("_total_fish", 0)
	instance.set("_best_stars_by_level", {1: 3})
	instance.call("_recalculate_best_stars")
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var shortage: Button = _assert_button(instance, "ShopYarnTrapKitShortageButton", "yarn trap shortage should expose a tappable shortage route")
	if shortage != null:
		shortage.emit_signal("pressed")
		await process_frame

	var shortage_overlay: Control = _assert_control(instance, "ShopInsufficientFishOverlay", "yarn shortage should open shortage feedback")
	var tasks_action: Button = _assert_button(instance, "GoDailyTaskFromShopShortageButton", "shortage feedback should expose daily-task action")
	if shortage_overlay != null and tasks_action != null:
		tasks_action.emit_signal("pressed")
		_assert_true(bool(shortage_overlay.get_meta("image2_overlay_exit_animation", false)), "shop shortage daily-task action should animate out before daily tasks")
		_assert_missing(instance, "DailyTaskOverlay", "shortage action should not hard-cut to daily task overlay")
		await _wait_until_missing(instance, "ShopInsufficientFishOverlay")
		await _wait_until_exists(instance, "DailyTaskOverlay")

	_assert_exists(instance, "DailyTaskOverlay", "shortage action should route to daily tasks")
	_assert_exists(instance, "ShopShortageDailyTaskGuidance", "shortage route should still show earning guidance before claim")
	var claim: Button = _assert_button(instance, "ClaimDailyTaskFirstClearButton", "guided daily task should expose ready first-clear claim")
	if claim != null:
		_assert_true(not claim.disabled, "guided first-clear claim should be enabled")
		claim.emit_signal("pressed")
		await process_frame
		await process_frame

	_assert_true(int(instance.get("_total_fish")) == 30, "claiming daily task from shop shortage should grant fish")
	var reward: Control = _assert_control(instance, "DailyTaskClaimRewardOverlay", "guided daily task claim should show reward overlay")
	var guidance: Control = _assert_control(instance, "DailyTaskShopReturnGuidance", "guided daily task claim should show shop-return guidance")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_daily_task_shop_return_guidance", false)), "daily task shop-return guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "daily task shop-return guidance should not block its route button")
	var badge: TextureRect = _assert_texture_node(instance, "DailyTaskShopReturnBadge", GUIDANCE_BADGE_PATH, "daily task shop-return guidance should show the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "daily task shop-return badge should not block route button")
	var label: Label = _assert_label(instance, "DailyTaskShopReturnLabel", "daily task shop-return guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("商店") or label.text.contains("购买"), "daily task shop-return copy should point back to buying")
	var route_button: Button = _assert_button(instance, "DailyTaskShopReturnButton", "daily task shop-return guidance should expose a shop route button")
	if reward != null and route_button != null:
		route_button.emit_signal("pressed")
		_assert_true(bool(reward.get_meta("image2_overlay_exit_animation", false)), "daily task shop-return route should animate the Image2 reward overlay out")
		_assert_true(route_button.disabled, "daily task shop-return route should disable while routing")
		_assert_missing(instance, "ShopOverlay", "daily task shop-return route should not hard-cut before reward exit")
		await _wait_until_missing(instance, "DailyTaskClaimRewardOverlay")
		await _wait_until_exists(instance, "ShopOverlay")

	_assert_exists(instance, "ShopOverlay", "daily task shop-return route should open the shop")
	_assert_missing(instance, "DailyTaskOverlay", "daily task shop-return route should leave daily tasks")
	var yarn_buy: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "returned shop should expose yarn trap buy button")
	if yarn_buy != null:
		_assert_true(not yarn_buy.disabled, "returned shop should make yarn trap purchase affordable after task reward")
	_assert_true(int(instance.get("_total_fish")) == 30, "routing back to shop should preserve earned fish")

	_cleanup_instance(instance)
	_finish()


func _new_instance() -> Node:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		return null
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	instance.set("_reward_date_override", "2026-06-20")
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
		print("DAILY TASK SHOP RETURN GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("DAILY TASK SHOP RETURN GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear daily task shop-return guidance test save: %s" % error)
