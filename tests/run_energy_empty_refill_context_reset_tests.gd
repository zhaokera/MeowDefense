extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_energy_empty_refill_context_reset_test_save.json"

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
	instance.set("_reward_date_override", "2026-06-20")
	instance.set("_energy_refilled_on", "2026-06-20")
	instance.set("_max_energy", 15)
	instance.set("_energy", 0)
	instance.set("_total_fish", 25)
	instance.set("_unlocked_level", 2)
	root.add_child(instance)
	await process_frame
	instance.set("_energy_refilled_on", "2026-06-20")
	instance.set("_energy", 0)
	instance.call("_show_level_select_now")
	await process_frame

	var level_two: Button = _assert_button(instance, "StartLevel2Button", "unlocked level two should be visible")
	if level_two != null:
		_assert_true(not level_two.disabled, "level two should be tappable before empty-energy feedback")
		level_two.emit_signal("pressed")
		await _wait_until_exists(instance, "EnergyEmptyOverlay")

	var close_empty: Button = _assert_button(instance, "CloseEnergyEmptyButton", "energy empty overlay should be dismissible")
	if close_empty != null:
		close_empty.emit_signal("pressed")
		await _wait_until_missing(instance, "EnergyEmptyOverlay")

	var shop: Button = _assert_button(instance, "BottomShopButton", "level select should expose bottom shop entry")
	if shop != null:
		shop.emit_signal("pressed")
		await _wait_until_exists(instance, "ShopOverlay")

	var buy_button: Button = _assert_button(instance, "BuyShopEnergyRefillButton", "shop should expose energy refill purchase")
	if buy_button != null:
		_assert_true(not buy_button.disabled, "direct shop refill should be affordable")
		buy_button.emit_signal("pressed")
		await _wait_until_exists(instance, "ShopEnergyRefillReturnButton")

	var return_button: Button = _assert_button(instance, "ShopEnergyRefillReturnButton", "energy refill reward should expose return-to-level action")
	if return_button != null:
		return_button.emit_signal("pressed")
		await _wait_frames(60)

	_assert_exists(instance, "LevelSelectScreen", "direct refill return should open level select")
	_assert_missing(instance, "Level2EnergyReadyGuidance", "dismissed empty-energy context should not leak into a later direct shop refill")
	var guidance: Control = _assert_control(instance, "Level1EnergyReadyGuidance", "direct shop refill should keep the default energy-ready guidance")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_energy_ready_guidance", false)), "default energy-ready guidance should remain Image2-sourced")
	var start_level: Button = _assert_button(instance, "StartLevel1Button", "default guided level should remain tappable")
	if start_level != null:
		_assert_true(not start_level.disabled, "default guided level should be enabled after refill")

	instance.queue_free()
	_finish()


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


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 300) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) != null:
			return
		await process_frame


func _wait_until_missing(root_node: Node, node_name: String, max_frames: int = 300) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) == null:
			return
		await process_frame


func _wait_frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("ENERGY EMPTY REFILL CONTEXT RESET TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ENERGY EMPTY REFILL CONTEXT RESET TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear energy empty context reset test save: %s" % error)
