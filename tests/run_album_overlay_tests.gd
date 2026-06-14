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

	_assert_exists(instance, "AlbumOverlay", "album should open as an overlay")
	_assert_texture_node(
		instance,
		"AlbumDesignPanel",
		"res://assets/generated/ui/album_overlay_panel.png",
		"album should use an Image2 panel asset"
	)
	_assert_texture_node(
		instance,
		"AlbumTowerCardFrame",
		"res://assets/generated/ui/album_card_frame.png",
		"album tower entry should use an Image2 card frame"
	)
	_assert_texture_node(
		instance,
		"AlbumMouseCardFrame",
		"res://assets/generated/ui/album_card_frame.png",
		"album mouse entry should use an Image2 card frame"
	)
	_assert_texture_node(
		instance,
		"AlbumBaseCardFrame",
		"res://assets/generated/ui/album_card_frame.png",
		"album base entry should use an Image2 card frame"
	)
	_assert_texture_node(
		instance,
		"AlbumCloseFrame",
		"res://assets/generated/ui/album_close_button.png",
		"album close should use an Image2 button frame"
	)
	_assert_missing(instance, "AlbumPanel", "album should not render the old code-drawn panel")
	_assert_missing(instance, "AlbumTowerCard", "album should not render old code-drawn tower card")
	_assert_missing(instance, "AlbumMouseCard", "album should not render old code-drawn mouse card")
	_assert_missing(instance, "AlbumBaseCard", "album should not render old code-drawn base card")

	var close_button: Button = _assert_button(instance, "CloseAlbumButton", "album should be closable")
	if close_button != null:
		close_button.emit_signal("pressed")
		await process_frame
		_assert_missing(instance, "AlbumOverlay", "album overlay should close")

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
		print("ALBUM OVERLAY TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ALBUM OVERLAY TESTS FAIL: %d" % _failures.size())
		quit(1)
