extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_achievement_claim_test_save.json"

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
	root.add_child(instance)
	await process_frame

	instance.set("_best_stars_by_level", {1: 3})
	instance.call("_recalculate_best_stars")
	instance.call("_show_achievements_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	_assert_design_texture(
		instance,
		"AchievementsDesignBackground",
		"res://assets/generated/ui/achievements_overlay_design_reference.png",
		"achievements should keep the Image2 full-screen design"
	)
	var claim_button: Button = _assert_button(instance, "AchievementFirstClearClaimButton", "first-clear achievement should expose a claim button")
	var claim_label: Label = _assert_label(instance, "AchievementFirstClearClaimLabel", "first-clear achievement should show a claim state label")
	if claim_label != null:
		_assert_true(claim_label.text.contains("领取"), "completed unclaimed achievement should be claimable")
	if claim_button != null:
		_assert_true(not claim_button.disabled, "completed unclaimed achievement claim button should be enabled")
		claim_button.emit_signal("pressed")
		await process_frame

	_assert_true(_int_property(instance, "_total_fish") == 10, "first-clear achievement should grant 10 fish")
	_assert_true(_int_property(instance, "_paw_tokens") == 1, "first-clear achievement should grant 1 paw token")
	_assert_true(_claimed(instance, "first_clear"), "first-clear achievement should be marked claimed")
	_assert_design_texture(
		instance,
		"AchievementFirstClearClaimedStamp",
		"res://assets/generated/ui/achievement_claimed_stamp.png",
		"claimed achievement should display the Image2 claimed stamp"
	)
	if claim_button != null:
		_assert_true(claim_button.disabled, "claimed achievement button should become disabled")
	if claim_label != null:
		_assert_true(claim_label.text == "已领取", "claimed achievement label should update")

	instance.queue_free()
	await process_frame

	var reloaded: Node = scene.instantiate()
	reloaded.set("_save_path", TEST_SAVE_PATH)
	root.add_child(reloaded)
	await process_frame
	reloaded.call("_show_achievements_overlay", reloaded.find_child("MainMenuScreen", true, false))
	await process_frame

	_assert_true(_int_property(reloaded, "_total_fish") == 10, "fish reward should persist after reload")
	_assert_true(_int_property(reloaded, "_paw_tokens") == 1, "paw token reward should persist after reload")
	_assert_true(_claimed(reloaded, "first_clear"), "claimed achievement should persist after reload")
	var reloaded_claim: Button = _assert_button(reloaded, "AchievementFirstClearClaimButton", "reloaded first-clear claim button should exist")
	if reloaded_claim != null:
		_assert_true(reloaded_claim.disabled, "claimed achievement should stay disabled after reload")

	var close_button: Button = _assert_button(reloaded, "CloseAchievementsButton", "achievements should still be closable")
	if close_button != null:
		close_button.emit_signal("pressed")
		await process_frame
	var bag_button: Button = _assert_button(reloaded, "BottomBagButton", "main menu should expose backpack")
	if bag_button != null:
		bag_button.emit_signal("pressed")
		await process_frame
	var paw_detail: Label = _assert_label(reloaded, "BackpackPawTokenItemDetail", "backpack should show paw token count")
	if paw_detail != null:
		_assert_true(paw_detail.text.contains("1"), "backpack paw token detail should reflect achievement reward")

	reloaded.queue_free()
	_finish()


func _claimed(instance: Node, achievement_id: String) -> bool:
	var raw: Variant = instance.get("_claimed_achievements")
	if raw is Dictionary:
		return bool((raw as Dictionary).get(achievement_id, false))
	return false


func _int_property(instance: Node, property_name: String) -> int:
	var raw: Variant = instance.get(property_name)
	if raw == null:
		return 0
	return int(raw)


func _assert_design_texture(root_node: Node, node_name: String, expected_path: String, message: String) -> void:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return
	if not node is TextureRect:
		_failures.append("%s should be a TextureRect" % node_name)
		return
	var rect: TextureRect = node as TextureRect
	_assert_true(rect.texture != null, "%s should have a texture" % node_name)
	if rect.texture != null:
		_assert_true(rect.texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])


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


func _assert_exists(root_node: Node, node_name: String, message: String) -> Node:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
	return node


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
		print("ACHIEVEMENT CLAIM TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ACHIEVEMENT CLAIM TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear achievement claim test save: %s" % error)
