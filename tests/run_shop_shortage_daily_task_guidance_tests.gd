extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_shop_shortage_daily_task_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/shop_shortage_daily_task_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/shop_shortage_daily_task_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/shop_shortage_daily_task_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "shop shortage daily-task route should keep an Image2 full-screen design reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "shop shortage daily-task route should keep an Image2-derived badge source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "shop shortage daily-task route should use a transparent runtime badge")
	_assert_manifest_entry("shop_shortage_daily_task_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("shop_shortage_daily_task_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("shop_shortage_daily_task_guidance_badge", GUIDANCE_BADGE_PATH)

	var normal: Node = await _new_instance()
	if normal != null:
		normal.set("_best_stars_by_level", {1: 3})
		normal.call("_recalculate_best_stars")
		var task_button: Button = _assert_button(normal, "DailyTaskButton", "main menu should expose daily task entry")
		if task_button != null:
			task_button.emit_signal("pressed")
			await process_frame
		_assert_exists(normal, "DailyTaskOverlay", "normal daily task entry should open daily tasks")
		_assert_missing(normal, "ShopShortageDailyTaskGuidance", "normal daily task visits should not show shop-shortage guidance")
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

	var shortage: Button = _assert_button(instance, "ShopPawBundleShortageButton", "paw bundle shortage should expose a tappable shortage route")
	if shortage != null:
		shortage.emit_signal("pressed")
		await process_frame

	var overlay: Control = _assert_control(instance, "ShopInsufficientFishOverlay", "shop shortage route should open the shortage feedback first")
	var action: Button = _assert_button(instance, "GoDailyTaskFromShopShortageButton", "shop shortage feedback should expose a daily-task action")
	if overlay != null and action != null:
		action.emit_signal("pressed")
		_assert_true(bool(overlay.get_meta("image2_overlay_exit_animation", false)), "shop shortage daily-task action should animate the Image2 shortage overlay out")
		_assert_true(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "shop shortage overlay should ignore input while routing")
		_assert_true(action.disabled, "shop shortage daily-task action should disable while routing")
		_assert_missing(instance, "DailyTaskOverlay", "shop shortage action should not hard-cut to daily tasks before exit")
		await _wait_until_missing(instance, "ShopInsufficientFishOverlay")
		await _wait_until_exists(instance, "DailyTaskOverlay")

	_assert_missing(instance, "ShopInsufficientFishOverlay", "shop shortage action should leave shortage overlay")
	_assert_exists(instance, "DailyTaskOverlay", "shop shortage action should open daily tasks")
	var guidance: Control = _assert_control(instance, "ShopShortageDailyTaskGuidance", "shop shortage action should show daily-task earning guidance")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_shop_shortage_daily_task_guidance", false)), "shop shortage daily-task guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "shop shortage daily-task guidance should not block task controls")
	var badge: TextureRect = _assert_texture_node(instance, "ShopShortageDailyTaskBadge", GUIDANCE_BADGE_PATH, "shop shortage daily-task guidance should show the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "shop shortage daily-task badge should not block task buttons")
	var label: Label = _assert_label(instance, "ShopShortageDailyTaskLabel", "shop shortage daily-task guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("任务") or label.text.contains("鱼干"), "shop shortage daily-task copy should point to earning fish from tasks")
	var claim: Button = _assert_button(instance, "ClaimDailyTaskFirstClearButton", "guided daily task claim should remain tappable")
	if claim != null:
		_assert_true(not claim.disabled, "guided ready daily task claim should remain enabled")
	_assert_true(int(instance.get("_total_fish")) == 0, "routing from shop shortage should not grant fish before claiming a task")

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
		print("SHOP SHORTAGE DAILY TASK GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SHOP SHORTAGE DAILY TASK GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear shop shortage daily-task guidance test save: %s" % error)
