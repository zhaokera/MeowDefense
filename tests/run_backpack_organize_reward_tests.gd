extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_backpack_organize_reward_test_save.json"

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

	instance.set("_total_fish", 10)
	instance.set("_paw_tokens", 2)
	instance.set("_yarn_traps", 1)
	instance.call("_show_backpack_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var fish_counter: Label = _assert_label(instance, "BackpackFishCounter", "backpack should show fish total")
	var organize_button: Button = _assert_button(instance, "OrganizeBackpackButton", "backpack should expose organize action")
	if fish_counter != null:
		_assert_true(fish_counter.text == "10", "backpack fish counter should start from current fish")
	if organize_button != null:
		_assert_true(organize_button.text == "整理背包", "fresh backpack should invite organization")
		_assert_true(not organize_button.disabled, "fresh organize button should be enabled")
		organize_button.emit_signal("pressed")
		await process_frame

	_assert_true(_int_property(instance, "_total_fish") == 15, "organizing backpack should grant five fish")
	_assert_true(_bool_property(instance, "_backpack_organized"), "organize reward should mark the backpack as organized")
	if fish_counter != null:
		_assert_true(fish_counter.text == "15", "backpack fish counter should update after organization")
	if organize_button != null:
		_assert_true(organize_button.text == "已整理", "organize button should update after claim")
		_assert_true(organize_button.disabled, "organize reward should not be claimable twice")

	_assert_exists(instance, "BackpackOrganizeRewardOverlay", "organizing backpack should show a reward overlay")
	_assert_design_texture(
		instance,
		"BackpackOrganizeRewardDesignBackground",
		"res://assets/generated/ui/backpack_organize_reward_design_reference.png",
		"organize reward should render from an Image2 full-screen design"
	)
	var reward_label: Label = _assert_label(instance, "BackpackOrganizeRewardAmount", "organize reward should show reward amount")
	if reward_label != null:
		_assert_true(reward_label.text.contains("+5"), "organize reward amount should mention +5 fish")

	instance.queue_free()
	await process_frame

	var reloaded: Node = scene.instantiate()
	reloaded.set("_save_path", TEST_SAVE_PATH)
	root.add_child(reloaded)
	await process_frame
	_assert_true(_int_property(reloaded, "_total_fish") == 15, "organize reward fish should persist after reload")
	_assert_true(_bool_property(reloaded, "_backpack_organized"), "organized state should persist after reload")
	reloaded.call("_show_backpack_overlay", reloaded.find_child("MainMenuScreen", true, false))
	await process_frame
	var reloaded_organize: Button = _assert_button(reloaded, "OrganizeBackpackButton", "reloaded backpack should still show organize action")
	if reloaded_organize != null:
		_assert_true(reloaded_organize.text == "已整理", "reloaded organize button should show claimed state")
		_assert_true(reloaded_organize.disabled, "reloaded organize reward should stay disabled")
	reloaded.queue_free()
	_finish()


func _int_property(instance: Node, property_name: String) -> int:
	var raw: Variant = instance.get(property_name)
	if raw == null:
		return 0
	return int(raw)


func _bool_property(instance: Node, property_name: String) -> bool:
	var raw: Variant = instance.get(property_name)
	if raw == null:
		return false
	return bool(raw)


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
		print("BACKPACK ORGANIZE REWARD TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BACKPACK ORGANIZE REWARD TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear backpack organize reward test save: %s" % error)
