extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_backpack_item_detail_test_save.json"

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

	instance.set("_total_fish", 60)
	instance.set("_paw_tokens", 3)
	instance.set("_yarn_traps", 2)
	instance.call("_show_backpack_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	_assert_design_texture(
		instance,
		"BackpackDesignBackground",
		"res://assets/generated/ui/backpack_overlay_design_reference.png",
		"backpack should keep the Image2 full-screen design"
	)

	var trap_button: Button = _assert_button(instance, "BackpackYarnTrapItemButton", "backpack should expose yarn trap item details")
	if trap_button != null:
		trap_button.emit_signal("pressed")
		await process_frame

	_assert_exists(instance, "BackpackItemDetailOverlay", "clicking a backpack item should open an item detail overlay")
	_assert_design_texture(
		instance,
		"BackpackItemDetailDesignBackground",
		"res://assets/generated/ui/backpack_item_detail_design_reference.png",
		"backpack item detail should render from an Image2 full-screen design"
	)
	_assert_design_texture(
		instance,
		"BackpackItemDetailIcon",
		"res://assets/generated/ui/yarn_trap_item_icon.png",
		"yarn trap detail should use the Image2 item icon"
	)
	var title: Label = _assert_label(instance, "BackpackItemDetailTitle", "item detail should show the item title")
	if title != null:
		_assert_true(title.text == "毛线陷阱", "yarn trap detail should show the selected item title")
	var count: Label = _assert_label(instance, "BackpackItemDetailCount", "item detail should show owned count")
	if count != null:
		_assert_true(count.text.contains("2"), "yarn trap detail should show the current owned count")
	var action: Button = _assert_button(instance, "BackpackItemDetailActionButton", "item detail should expose a contextual action")
	if action != null:
		_assert_true(action.text == "去战斗", "yarn trap detail should guide the player to battle")
		action.emit_signal("pressed")
		for _frame: int in range(45):
			await process_frame
		_assert_missing(instance, "BackpackOverlay", "item detail action should close the backpack overlay")
		_assert_exists(instance, "LevelSelectScreen", "yarn trap detail action should take the player to level select")

	instance.queue_free()
	_finish()


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


func _assert_missing(root_node: Node, node_name: String, message: String) -> void:
	if _find_by_name(root_node, node_name) != null:
		_failures.append(message)


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
		print("BACKPACK ITEM DETAIL TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BACKPACK ITEM DETAIL TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear backpack item detail test save: %s" % error)
