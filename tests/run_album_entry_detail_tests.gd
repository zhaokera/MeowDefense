extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish()
		return

	var instance: Node = scene.instantiate()
	root.add_child(instance)
	await process_frame

	var album_button: Button = _assert_button(instance, "AlbumButton", "main menu should expose the album button")
	if album_button != null:
		album_button.emit_signal("pressed")
		await process_frame

	var inspect_button: Button = _assert_button(instance, "AlbumTowerInspectButton", "album tower card should be inspectable")
	if inspect_button != null:
		inspect_button.emit_signal("pressed")
		await process_frame

	_assert_exists(instance, "AlbumEntryDetailOverlay", "inspecting an album card should open a dedicated detail overlay")
	_assert_texture_node(
		instance,
		"AlbumEntryDetailDesignBackground",
		"res://assets/generated/ui/album_entry_detail_design_reference.png",
		"album entry detail should render from an Image2 full-screen design"
	)
	_assert_sprite_texture(
		instance,
		"AlbumEntryDetailPortraitSprite",
		"res://assets/generated/towers/orange_cat_tower.png",
		"tower detail should show the selected tower art"
	)
	var title: Label = _assert_label(instance, "AlbumEntryDetailTitle", "entry detail should show a title")
	if title != null:
		_assert_true(title.text == "橘猫鱼骨炮", "tower detail should show the selected tower title")
	var role: Label = _assert_label(instance, "AlbumEntryDetailRole", "entry detail should show role text")
	if role != null:
		_assert_true(role.text.contains("单体输出"), "tower detail should show its role")
	var action_button: Button = _assert_button(instance, "AlbumEntryDetailActionButton", "entry detail should expose a contextual action")
	if action_button != null:
		_assert_true(action_button.text == "去关卡", "album detail action should route to level select")
		action_button.emit_signal("pressed")
		for _frame: int in range(45):
			await process_frame
		_assert_missing(instance, "AlbumOverlay", "album detail action should close the album overlay")
		_assert_exists(instance, "LevelSelectScreen", "album detail action should take the player to level select")

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


func _assert_sprite_texture(root_node: Node, node_name: String, expected_path: String, message: String) -> Sprite2D:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if not node is Sprite2D:
		_failures.append("%s should be a Sprite2D" % node_name)
		return null
	var sprite: Sprite2D = node as Sprite2D
	_assert_true(sprite.texture != null, "%s should have a texture" % node_name)
	if sprite.texture != null:
		_assert_true(sprite.texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])
	return sprite


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
	if _failures.is_empty():
		print("ALBUM ENTRY DETAIL TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ALBUM ENTRY DETAIL TESTS FAIL: %d" % _failures.size())
		quit(1)
