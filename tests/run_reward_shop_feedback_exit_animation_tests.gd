extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_reward_shop_feedback_exit_animation_test_save.json"

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

	var backpack_instance: Node = await _new_instance(scene)
	await _open_backpack_organize_reward(backpack_instance)
	await _assert_overlay_exit_animation(backpack_instance, "BackpackOrganizeRewardOverlay", "CloseBackpackOrganizeRewardButton", "backpack organize reward")
	backpack_instance.queue_free()
	await process_frame

	var achievement_instance: Node = await _new_instance(scene)
	await _open_achievement_claim_reward(achievement_instance)
	await _assert_overlay_exit_animation(achievement_instance, "AchievementClaimRewardOverlay", "CloseAchievementClaimRewardButton", "achievement claim reward")
	achievement_instance.queue_free()
	await process_frame

	var shop_purchase_instance: Node = await _new_instance(scene)
	await _open_shop_purchase_reward(shop_purchase_instance)
	await _assert_overlay_exit_animation(shop_purchase_instance, "ShopPurchaseRewardOverlay", "CloseShopPurchaseRewardButton", "shop purchase reward")
	shop_purchase_instance.queue_free()
	await process_frame

	var shortage_instance: Node = await _new_instance(scene)
	await _open_shop_insufficient_fish_feedback(shortage_instance)
	await _assert_overlay_exit_animation(shortage_instance, "ShopInsufficientFishOverlay", "CloseShopInsufficientFishButton", "shop insufficient fish")
	shortage_instance.queue_free()

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


func _open_backpack_organize_reward(instance: Node) -> void:
	instance.set("_total_fish", 10)
	instance.set("_paw_tokens", 2)
	instance.set("_yarn_traps", 1)
	var backpack_button: Button = _find_by_name(instance, "BottomBagButton") as Button
	if backpack_button == null:
		_failures.append("bottom backpack button should exist for organize reward")
		return
	backpack_button.emit_signal("pressed")
	await process_frame
	var organize_button: Button = _find_by_name(instance, "OrganizeBackpackButton") as Button
	if organize_button == null:
		_failures.append("organize backpack button should exist")
		return
	organize_button.emit_signal("pressed")
	await process_frame
	await process_frame


func _open_achievement_claim_reward(instance: Node) -> void:
	instance.set("_best_stars_by_level", {1: 3})
	instance.call("_recalculate_best_stars")
	var achievements_button: Button = _find_by_name(instance, "BottomAchievementsButton") as Button
	if achievements_button == null:
		_failures.append("bottom achievements button should exist for claim reward")
		return
	achievements_button.emit_signal("pressed")
	await process_frame
	var claim_button: Button = _find_by_name(instance, "AchievementFirstClearClaimButton") as Button
	if claim_button == null:
		_failures.append("achievement first-clear claim button should exist")
		return
	claim_button.emit_signal("pressed")
	await process_frame
	await process_frame


func _open_shop_purchase_reward(instance: Node) -> void:
	instance.set("_total_fish", 110)
	instance.set("_max_energy", 15)
	instance.set("_energy", 0)
	instance.set("_energy_refilled_on", "2026-06-19")
	instance.set("_reward_date_override", "2026-06-19")
	var shop_button: Button = _find_by_name(instance, "BottomShopButton") as Button
	if shop_button == null:
		_failures.append("bottom shop button should exist for purchase reward")
		return
	shop_button.emit_signal("pressed")
	await process_frame
	var purchase_button: Button = _find_by_name(instance, "BuyShopPawBundleButton") as Button
	if purchase_button == null:
		_failures.append("shop paw bundle buy button should exist")
		return
	purchase_button.emit_signal("pressed")
	await process_frame
	await process_frame


func _open_shop_insufficient_fish_feedback(instance: Node) -> void:
	instance.set("_shop_starter_claimed", true)
	instance.set("_total_fish", 0)
	var shop_button: Button = _find_by_name(instance, "BottomShopButton") as Button
	if shop_button == null:
		_failures.append("bottom shop button should exist for insufficient fish")
		return
	shop_button.emit_signal("pressed")
	await process_frame
	var shortage_button: Button = _find_by_name(instance, "ShopPawBundleShortageButton") as Button
	if shortage_button == null:
		_failures.append("shop paw bundle shortage button should exist")
		return
	shortage_button.emit_signal("pressed")
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
		_assert_true(overlay.modulate.a < 1.0, "%s overlay should start fading out immediately during exit animation" % label)
	_assert_true(close_button.disabled, "%s close button should disable during exit animation" % label)
	for _frame: int in range(45):
		await process_frame
	_assert_true(_find_by_name(instance, overlay_name) == null, "%s overlay should be removed after exit animation" % label)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear reward/shop exit animation test save: %s" % error)


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
		print("REWARD SHOP FEEDBACK EXIT ANIMATION TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("REWARD SHOP FEEDBACK EXIT ANIMATION TESTS FAIL: %d" % _failures.size())
		quit(1)
