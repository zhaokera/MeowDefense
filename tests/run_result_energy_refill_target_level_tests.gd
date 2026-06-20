extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_result_energy_refill_target_level_test_save.json"

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
	instance.set("_current_level_id", 1)
	instance.set("_unlocked_level", 2)
	instance.set("_claimed_achievements", {"first_clear": true})
	root.add_child(instance)
	await process_frame
	instance.set("_energy_refilled_on", "2026-06-20")
	instance.set("_energy", 0)
	instance.call("_show_result", true, 3, 0)
	await process_frame

	var next_button: Button = _assert_button(instance, "NextLevelButton", "victory result should expose next-level action")
	if next_button != null:
		next_button.emit_signal("pressed")
		await _wait_until_exists(instance, "ResultEnergyRefillGuidance")

	var result_refill: Button = _assert_button(instance, "ResultEnergyRefillButton", "result refill guidance should expose a shop route")
	if result_refill != null:
		result_refill.emit_signal("pressed")
		await _wait_until_exists(instance, "ShopOverlay")

	var buy_button: Button = _assert_button(instance, "BuyShopEnergyRefillButton", "shop should expose energy refill purchase")
	if buy_button != null:
		_assert_true(not buy_button.disabled, "energy refill should be affordable after result-route shop open")
		buy_button.emit_signal("pressed")
		await _wait_until_exists(instance, "ShopPurchaseRewardOverlay")

	var return_button: Button = _assert_button(instance, "ShopEnergyRefillReturnButton", "energy refill reward should expose return-to-level action")
	if return_button != null:
		return_button.emit_signal("pressed")
		await _wait_until_exists(instance, "LevelSelectScreen")

	_assert_exists(instance, "LevelSelectScreen", "refill return should open level select")
	_assert_missing(instance, "Level1EnergyReadyGuidance", "result refill return should not guide players back to an already-cleared level one")
	var guidance: Control = _assert_control(instance, "Level2EnergyReadyGuidance", "result refill return should guide the next-level target")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_energy_ready_guidance", false)), "target-level energy guidance should remain Image2-sourced")
	var badge: TextureRect = _assert_texture_node(
		instance,
		"Level2EnergyReadyBadge",
		"res://assets/generated/ui/level_select_energy_ready_badge.png",
		"target-level energy guidance should reuse the Image2 ready badge"
	)
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "target-level energy badge should not block the level hit area")
	var start_level: Button = _assert_button(instance, "StartLevel2Button", "guided next level should remain tappable")
	if start_level != null:
		_assert_true(not start_level.disabled, "guided next level should be enabled")
		start_level.emit_signal("pressed")
		await _wait_until_exists(instance, "BattleScene")

	_assert_exists(instance, "BattleScene", "pressing guided next level should enter battle")
	_assert_true(_int_property(instance, "_current_level_id") == 2, "guided battle should start level two")
	_assert_true(_int_property(instance, "_energy") == 4, "starting the guided level should consume one purchased energy")

	instance.queue_free()
	_finish()


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


func _int_property(instance: Node, property_name: String) -> int:
	var raw: Variant = instance.get(property_name)
	if raw == null:
		return 0
	return int(raw)


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


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("RESULT ENERGY REFILL TARGET LEVEL TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("RESULT ENERGY REFILL TARGET LEVEL TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear result energy refill target level test save: %s" % error)
