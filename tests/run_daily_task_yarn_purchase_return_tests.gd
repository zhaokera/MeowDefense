extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_daily_task_yarn_purchase_return_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/daily_task_yarn_purchase_return_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/daily_task_yarn_purchase_return_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/daily_task_yarn_purchase_return_guidance_badge.png"

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

	var normal: Node = await _new_instance(scene)
	if normal != null:
		normal.set("_total_fish", 40)
		normal.call("_show_shop_overlay", normal.find_child("MainMenuScreen", true, false))
		await process_frame
		var normal_buy: Button = _assert_button(normal, "BuyShopYarnTrapKitButton", "normal shop should expose yarn buy button")
		if normal_buy != null:
			normal_buy.emit_signal("pressed")
			await process_frame
			await process_frame
		_assert_exists(normal, "ShopYarnPurchaseBackpackGuidance", "normal yarn purchase should keep backpack guidance")
		_assert_missing(normal, "DailyTaskYarnPurchaseReturnGuidance", "normal yarn purchase should not show daily-task return guidance")
		_cleanup_instance(normal)

	var instance: Node = await _new_instance(scene)
	if instance == null:
		_finish()
		return
	instance.set("_total_fish", 25)
	var before_fish: int = int(instance.get("_total_fish"))

	var task_button: Button = _assert_button(instance, "DailyTaskButton", "main menu should expose daily task entry")
	if task_button != null:
		task_button.emit_signal("pressed")
		await process_frame
	var progress_button: Button = _assert_button(instance, "DailyTaskYarnProgressButton", "unfinished yarn task should expose progress hit area")
	if progress_button != null:
		progress_button.emit_signal("pressed")
		await _wait_until_exists(instance, "GoShopFromDailyTaskProgressButton")
	var shop_action: Button = _assert_button(instance, "GoShopFromDailyTaskProgressButton", "yarn task progress should expose shop route")
	if shop_action != null:
		shop_action.emit_signal("pressed")
		await _wait_until_exists(instance, "ShopOverlay")

	var yarn_buy: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "daily-task shop route should expose yarn buy button")
	if yarn_buy != null:
		_assert_true(not yarn_buy.disabled, "daily-task shop route should leave yarn affordable")
		yarn_buy.emit_signal("pressed")
		await process_frame
		await process_frame

	_assert_true(int(instance.get("_total_fish")) == before_fish - 25, "daily-task yarn purchase should spend fish")
	_assert_true(int(instance.get("_yarn_traps")) == 1, "daily-task yarn purchase should add yarn inventory")
	var reward: Control = _assert_control(instance, "ShopPurchaseRewardOverlay", "daily-task yarn purchase should show purchase reward")
	_assert_missing(instance, "ShopYarnPurchaseBackpackGuidance", "daily-task yarn purchase should not send the player to backpack first")
	var guidance: Control = _assert_control(instance, "DailyTaskYarnPurchaseReturnGuidance", "daily-task yarn purchase should show return-to-task guidance")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_daily_task_yarn_purchase_return_guidance", false)), "daily-task yarn return guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "daily-task yarn return guidance should not block its route button")
	_assert_texture_node(instance, "DailyTaskYarnPurchaseReturnBadge", GUIDANCE_BADGE_PATH, "daily-task yarn return guidance should render the Image2 badge")
	var label: Label = _assert_label(instance, "DailyTaskYarnPurchaseReturnLabel", "daily-task yarn return guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("任务") or label.text.contains("领取"), "daily-task yarn return guidance should point back to daily task reward")
	var return_button: Button = _assert_button(instance, "DailyTaskYarnPurchaseReturnButton", "daily-task yarn return guidance should expose a return route")
	if reward != null and return_button != null:
		return_button.emit_signal("pressed")
		_assert_true(bool(reward.get_meta("image2_overlay_exit_animation", false)), "daily-task yarn return should animate the Image2 purchase overlay out")
		_assert_true(return_button.disabled, "daily-task yarn return button should disable while routing")
		_assert_missing(instance, "DailyTaskOverlay", "daily-task yarn return should not hard-cut before purchase exit")
		await _wait_until_missing(instance, "ShopPurchaseRewardOverlay")
		await _wait_until_exists(instance, "DailyTaskOverlay")

	_assert_exists(instance, "DailyTaskOverlay", "daily-task yarn return should open daily tasks")
	_assert_missing(instance, "ShopOverlay", "daily-task yarn return should close shop overlay")
	var ready_progress: Label = _assert_label(instance, "DailyTaskYarnProgress", "returned daily task should show yarn progress")
	if ready_progress != null:
		_assert_true(ready_progress.text.contains("1/1"), "returned yarn task should be ready after purchase")
	var claim_button: Button = _assert_button(instance, "ClaimDailyTaskYarnButton", "returned yarn task should expose claim button")
	if claim_button != null:
		_assert_true(not claim_button.disabled, "returned yarn task should be claimable")
		claim_button.emit_signal("pressed")
		await process_frame
	_assert_true(int(instance.get("_total_fish")) == before_fish - 25 + 15, "claiming returned yarn daily task should grant reward fish")

	_assert_manifest_entry("daily_task_yarn_purchase_return_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("daily_task_yarn_purchase_return_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("daily_task_yarn_purchase_return_guidance_badge", GUIDANCE_BADGE_PATH)

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


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 180) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) != null:
			return
		await process_frame


func _wait_until_missing(root_node: Node, node_name: String, max_frames: int = 180) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) == null:
			return
		await process_frame


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
	return null


func _assert_control(root_node: Node, node_name: String, message: String) -> Control:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Control:
		return node as Control
	_failures.append("%s should be a Control" % node_name)
	return null


func _assert_texture_node(root_node: Node, node_name: String, expected_path: String, message: String) -> TextureRect:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if not node is TextureRect:
		_failures.append("%s should be a TextureRect" % node_name)
		return null
	var texture_node: TextureRect = node as TextureRect
	_assert_true(texture_node.texture != null, "%s should have a texture" % node_name)
	if texture_node.texture != null:
		_assert_true(texture_node.texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])
	return texture_node


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
		print("DAILY TASK YARN PURCHASE RETURN TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("DAILY TASK YARN PURCHASE RETURN TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear daily task yarn purchase return test save: %s" % error)
