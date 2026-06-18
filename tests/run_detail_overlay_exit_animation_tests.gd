extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_detail_overlay_exit_animation_test_save.json"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish(null)
		return
	var album_instance: Node = await _new_instance(scene)
	await _open_album_entry_detail(album_instance)
	await _assert_overlay_exit_animation(album_instance, "AlbumEntryDetailOverlay", "CloseAlbumEntryDetailButton", "album entry detail")
	album_instance.queue_free()
	await process_frame

	var backpack_instance: Node = await _new_instance(scene)
	await _open_backpack_item_detail(backpack_instance)
	await _assert_overlay_exit_animation(backpack_instance, "BackpackItemDetailOverlay", "CloseBackpackItemDetailButton", "backpack item detail")
	backpack_instance.queue_free()
	await process_frame

	var achievement_instance: Node = await _new_instance(scene)
	await _open_achievement_progress_guidance(achievement_instance)
	await _assert_overlay_exit_animation(achievement_instance, "AchievementProgressGuidanceOverlay", "CloseAchievementProgressGuidanceButton", "achievement progress guidance")
	achievement_instance.queue_free()

	_finish(null)


func _new_instance(scene: PackedScene) -> Node:
	var instance: Node = scene.instantiate()
	if instance == null:
		_failures.append("main scene should instantiate")
		return null
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame
	await process_frame
	return instance


func _open_album_entry_detail(instance: Node) -> void:
	var album_button: Button = _find_by_name(instance, "AlbumButton") as Button
	if album_button == null:
		_failures.append("album button should exist")
		return
	album_button.emit_signal("pressed")
	await process_frame
	var inspect_button: Button = _find_by_name(instance, "AlbumTowerInspectButton") as Button
	if inspect_button == null:
		_failures.append("album tower inspect button should exist")
		return
	inspect_button.emit_signal("pressed")
	await process_frame
	await process_frame


func _open_backpack_item_detail(instance: Node) -> void:
	instance.set("_total_fish", 60)
	instance.set("_paw_tokens", 3)
	instance.set("_yarn_traps", 2)
	var backpack_button: Button = _find_by_name(instance, "BottomBagButton") as Button
	if backpack_button == null:
		_failures.append("bottom backpack button should exist for backpack detail")
		return
	backpack_button.emit_signal("pressed")
	await process_frame
	var item_button: Button = _find_by_name(instance, "BackpackYarnTrapItemButton") as Button
	if item_button == null:
		_failures.append("backpack yarn trap item button should exist")
		return
	item_button.emit_signal("pressed")
	await process_frame
	await process_frame


func _open_achievement_progress_guidance(instance: Node) -> void:
	var achievements_button: Button = _find_by_name(instance, "BottomAchievementsButton") as Button
	if achievements_button == null:
		_failures.append("bottom achievements button should exist for achievement guidance")
		return
	achievements_button.emit_signal("pressed")
	await process_frame
	var row_button: Button = _find_by_name(instance, "AchievementFirstClearButton") as Button
	if row_button == null:
		_failures.append("achievement first-clear row button should exist")
		return
	row_button.emit_signal("pressed")
	await process_frame
	await process_frame


func _assert_overlay_exit_animation(instance: Node, overlay_name: String, close_button_name: String, label: String) -> void:
	var overlay: Control = _find_by_name(instance, overlay_name) as Control
	var close_button: Button = _find_by_name(instance, close_button_name) as Button
	if overlay == null:
		_failures.append("%s overlay should exist before closing" % label)
		return
	if close_button == null:
		_failures.append("%s close button should exist" % label)
		return

	close_button.emit_signal("pressed")
	_assert_true(is_instance_valid(overlay), "%s overlay should remain alive for exit animation immediately after close" % label)
	if is_instance_valid(overlay):
		_assert_true(overlay.get_meta("image2_overlay_exit_animation", false), "%s overlay should mark Image2 exit animation metadata" % label)
		_assert_true(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "%s overlay should stop catching input while exiting" % label)
	_assert_true(close_button.disabled, "%s close button should disable during exit animation" % label)
	await process_frame
	if not is_instance_valid(overlay):
		_failures.append("%s overlay should still exist during the first exit animation frame" % label)
	else:
		_assert_true(overlay.modulate.a < 1.0, "%s overlay should start fading out during exit animation" % label)
	for _frame: int in range(45):
		await process_frame
	_assert_true(_find_by_name(instance, overlay_name) == null, "%s overlay should be removed after exit animation" % label)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear detail overlay exit animation test save: %s" % error)


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish(instance: Node) -> void:
	_clear_save_file()
	if instance != null:
		instance.queue_free()
	if _failures.is_empty():
		print("DETAIL OVERLAY EXIT ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("DETAIL OVERLAY EXIT ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
