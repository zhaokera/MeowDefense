extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_overlay_action_exit_animation_test_save.json"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await _assert_locked_level_action_exits_before_starting_battle()
	await _assert_album_detail_action_exits_before_level_select()
	await _assert_backpack_detail_action_exits_before_level_select()
	await _assert_achievement_guidance_action_exits_before_level_select()
	await _assert_shop_shortage_action_exits_before_daily_tasks()
	_finish()


func _assert_locked_level_action_exits_before_starting_battle() -> void:
	var instance: Node = await _main_instance()
	if instance == null:
		return
	instance.call("_show_level_select_now")
	await process_frame
	var locked_info: Button = _find_by_name(instance, "LockedLevel2InfoButton") as Button
	if locked_info != null:
		locked_info.emit_signal("pressed")
		await process_frame
	var overlay: Control = _find_by_name(instance, "LockedLevelFeedbackOverlay") as Control
	var action: Button = _find_by_name(instance, "PlayPreviousLevelButton") as Button
	if overlay == null or action == null:
		_failures.append("locked level action overlay and action button should exist")
		_cleanup_instance(instance)
		return

	action.emit_signal("pressed")
	_assert_action_exit_started(instance, overlay, action, "locked level action")
	_assert_missing(instance, "BattleScene", "locked level action should not hard-cut to battle before exit animation")
	await _wait_frames(45)
	_assert_exists(instance, "BattleScene", "locked level action should start battle after exit animation")
	_assert_true(int(instance.get("_current_level_id")) == 1, "locked level action should still start the previous level")
	_cleanup_instance(instance)


func _assert_album_detail_action_exits_before_level_select() -> void:
	var instance: Node = await _main_instance()
	if instance == null:
		return
	var album_button: Button = _find_by_name(instance, "AlbumButton") as Button
	if album_button != null:
		album_button.emit_signal("pressed")
		await process_frame
	var inspect: Button = _find_by_name(instance, "AlbumTowerInspectButton") as Button
	if inspect != null:
		inspect.emit_signal("pressed")
		await process_frame
	var overlay: Control = _find_by_name(instance, "AlbumEntryDetailOverlay") as Control
	var action: Button = _find_by_name(instance, "AlbumEntryDetailActionButton") as Button
	if overlay == null or action == null:
		_failures.append("album detail action overlay and action button should exist")
		_cleanup_instance(instance)
		return

	action.emit_signal("pressed")
	_assert_action_exit_started(instance, overlay, action, "album detail action")
	_assert_missing(instance, "LevelSelectScreen", "album detail action should not hard-cut to level select before exit animation")
	await _wait_frames(45)
	_assert_exists(instance, "LevelSelectScreen", "album detail action should open level select after exit animation")
	_cleanup_instance(instance)


func _assert_backpack_detail_action_exits_before_level_select() -> void:
	var instance: Node = await _main_instance()
	if instance == null:
		return
	instance.set("_yarn_traps", 2)
	var main_screen: Node = _find_by_name(instance, "MainMenuScreen")
	instance.call("_show_backpack_overlay", main_screen)
	await process_frame
	var trap_button: Button = _find_by_name(instance, "BackpackYarnTrapItemButton") as Button
	if trap_button != null:
		trap_button.emit_signal("pressed")
		await process_frame
	var overlay: Control = _find_by_name(instance, "BackpackItemDetailOverlay") as Control
	var action: Button = _find_by_name(instance, "BackpackItemDetailActionButton") as Button
	if overlay == null or action == null:
		_failures.append("backpack detail action overlay and action button should exist")
		_cleanup_instance(instance)
		return

	action.emit_signal("pressed")
	_assert_action_exit_started(instance, overlay, action, "backpack detail action")
	_assert_missing(instance, "LevelSelectScreen", "backpack detail action should not hard-cut to level select before exit animation")
	await _wait_frames(45)
	_assert_exists(instance, "LevelSelectScreen", "backpack detail action should open level select after exit animation")
	_cleanup_instance(instance)


func _assert_achievement_guidance_action_exits_before_level_select() -> void:
	var instance: Node = await _main_instance()
	if instance == null:
		return
	instance.call("_show_achievements_overlay", _find_by_name(instance, "MainMenuScreen"))
	await process_frame
	var row_button: Button = _find_by_name(instance, "AchievementFirstClearButton") as Button
	if row_button != null:
		row_button.emit_signal("pressed")
		await process_frame
	var overlay: Control = _find_by_name(instance, "AchievementProgressGuidanceOverlay") as Control
	var action: Button = _find_by_name(instance, "GoLevelsFromAchievementProgressButton") as Button
	if overlay == null or action == null:
		_failures.append("achievement guidance action overlay and action button should exist")
		_cleanup_instance(instance)
		return

	action.emit_signal("pressed")
	_assert_action_exit_started(instance, overlay, action, "achievement guidance action")
	_assert_missing(instance, "LevelSelectScreen", "achievement guidance action should not hard-cut to level select before exit animation")
	await _wait_frames(45)
	_assert_exists(instance, "LevelSelectScreen", "achievement guidance action should open level select after exit animation")
	_cleanup_instance(instance)


func _assert_shop_shortage_action_exits_before_daily_tasks() -> void:
	var instance: Node = await _main_instance()
	if instance == null:
		return
	instance.set("_shop_starter_claimed", true)
	instance.set("_total_fish", 0)
	instance.call("_show_shop_overlay", _find_by_name(instance, "MainMenuScreen"))
	await process_frame
	var shortage: Button = _find_by_name(instance, "ShopPawBundleShortageButton") as Button
	if shortage != null:
		shortage.emit_signal("pressed")
		await process_frame
	var overlay: Control = _find_by_name(instance, "ShopInsufficientFishOverlay") as Control
	var action: Button = _find_by_name(instance, "GoDailyTaskFromShopShortageButton") as Button
	if overlay == null or action == null:
		_failures.append("shop shortage action overlay and action button should exist")
		_cleanup_instance(instance)
		return

	action.emit_signal("pressed")
	_assert_action_exit_started(instance, overlay, action, "shop shortage action")
	_assert_missing(instance, "DailyTaskOverlay", "shop shortage action should not hard-cut to daily tasks before exit animation")
	await _wait_frames(45)
	_assert_exists(instance, "DailyTaskOverlay", "shop shortage action should open daily tasks after exit animation")
	_cleanup_instance(instance)


func _main_instance() -> Node:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		return null
	var instance: Node = scene.instantiate()
	if instance == null:
		_failures.append("main scene should instantiate")
		return null
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame
	return instance


func _assert_action_exit_started(root_node: Node, overlay: Control, trigger_button: Button, label: String) -> void:
	_assert_true(is_instance_valid(overlay), "%s overlay should remain alive during exit animation" % label)
	if not is_instance_valid(overlay):
		return
	_assert_true(bool(overlay.get_meta("image2_overlay_exit_animation", false)), "%s should mark Image2 overlay exit metadata" % label)
	_assert_true(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "%s overlay should ignore input while exiting" % label)
	_assert_true(overlay.modulate.a < 1.0, "%s overlay should start fading immediately" % label)
	_assert_true(trigger_button.disabled, "%s pressed action should disable during exit animation" % label)
	_assert_true(_find_by_name(root_node, overlay.name) != null, "%s overlay should still be present immediately after action press" % label)


func _wait_frames(count: int) -> void:
	for _frame: int in range(count):
		await process_frame


func _cleanup_instance(instance: Node) -> void:
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	_clear_save_file()


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear overlay action exit animation test save: %s" % error)


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


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("OVERLAY ACTION EXIT ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("OVERLAY ACTION EXIT ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
