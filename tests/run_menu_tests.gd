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
	if instance == null:
		_failures.append("main scene should instantiate")
		_finish()
		return

	root.add_child(instance)
	await process_frame

	_assert_exists(instance, "MainMenuScreen", "main menu should render first")
	var design_background: TextureRect = _assert_texture_rect(instance, "Image2DesignBackground", "main menu should use the Image2 design background")
	if design_background != null and design_background.texture != null:
		_assert_true(design_background.texture.resource_path == "res://assets/generated/ui/main_menu_design_reference.png", "main menu should render from the Image2 design asset")
	_assert_missing(instance, "TitleBadge", "main menu should not rebuild the Image2 title plaque with code panels")
	_assert_missing(instance, "HeroPanel", "main menu should not rebuild the Image2 mission card with code panels")
	var start_button: Button = _assert_button(instance, "StartLevelSelectButton", "main menu should expose a start button")
	var settings_button: Button = _assert_button(instance, "SettingsButton", "main menu should expose settings")
	var album_button: Button = _assert_button(instance, "AlbumButton", "main menu should expose an album/guide")

	if settings_button != null:
		settings_button.emit_signal("pressed")
		await process_frame
		_assert_exists(instance, "SettingsOverlay", "settings should open as an overlay")
		_assert_exists(instance, "MusicToggle", "settings should include a music toggle")
		_assert_exists(instance, "EffectsToggle", "settings should include an effects toggle")
		_assert_exists(instance, "VolumeSlider", "settings should include a volume slider")
		var close_settings: Button = _assert_button(instance, "CloseSettingsButton", "settings should be closable")
		if close_settings != null:
			close_settings.emit_signal("pressed")
			await process_frame
			_assert_missing(instance, "SettingsOverlay", "settings overlay should close")

	if album_button != null:
		album_button.emit_signal("pressed")
		await process_frame
		_assert_exists(instance, "AlbumOverlay", "album should open as an overlay")
		var close_album: Button = _assert_button(instance, "CloseAlbumButton", "album should be closable")
		if close_album != null:
			close_album.emit_signal("pressed")
			await process_frame
			_assert_missing(instance, "AlbumOverlay", "album overlay should close")

	if start_button != null:
		start_button.emit_signal("pressed")
		await process_frame
		_assert_exists(instance, "LevelSelectScreen", "start button should show level select")
		var back_button: Button = _assert_button(instance, "BackToMainButton", "level select should return to main menu")
		if back_button != null:
			back_button.emit_signal("pressed")
			await process_frame
			_assert_exists(instance, "MainMenuScreen", "back button should return to main menu")
			start_button = _assert_button(instance, "StartLevelSelectButton", "main menu start should still exist after returning")
			if start_button != null:
				start_button.emit_signal("pressed")
				await process_frame
		var level_button: Button = _assert_button(instance, "StartLevel1Button", "level select should start level one")
		for level_index: int in range(1, 6):
			_assert_button(instance, "StartLevel%dButton" % level_index, "level select should expose level %d" % level_index)
		_assert_level_select_layout(instance)
		if level_button != null:
			level_button.emit_signal("pressed")
			await process_frame
			_assert_exists(instance, "BattleScene", "level one should start the battle scene")
			var pause_button: Button = _assert_button(instance, "PauseButton", "battle HUD should expose pause")
			if pause_button != null:
				pause_button.emit_signal("pressed")
				await process_frame
				_assert_exists(instance, "PauseMenuOverlay", "pause should open a full pause menu")
				var resume_button: Button = _assert_button(instance, "ResumeButton", "pause menu should resume")
				var quit_button: Button = _assert_button(instance, "QuitToLevelsButton", "pause menu should return to level select")
				if resume_button != null:
					resume_button.emit_signal("pressed")
					await process_frame
					_assert_missing(instance, "PauseMenuOverlay", "resume should close pause menu")
					pause_button = _assert_button(instance, "PauseButton", "pause button should still exist after resume")
					if pause_button != null:
						pause_button.emit_signal("pressed")
						await process_frame
						quit_button = _assert_button(instance, "QuitToLevelsButton", "pause menu should return to level select")
				if quit_button != null:
					quit_button.emit_signal("pressed")
					await process_frame
					_assert_exists(instance, "LevelSelectScreen", "quit from pause should return to level select")
					var level_two_button: Button = _assert_button(instance, "StartLevel2Button", "level select should start level two")
					if level_two_button != null:
						level_two_button.emit_signal("pressed")
						await process_frame
						_assert_exists(instance, "BattleScene", "level two should start the battle scene")
						_assert_button(instance, "SelectTowerTabbySlowCatButton", "battle HUD should expose the slow tower selector")

	instance.queue_free()
	_finish()


func _finish() -> void:
	if _failures.is_empty():
		print("MENU TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("MENU TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_exists(root_node: Node, node_name: String, message: String) -> Node:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
	return node


func _assert_missing(root_node: Node, node_name: String, message: String) -> void:
	if _find_by_name(root_node, node_name) != null:
		_failures.append(message)


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


func _assert_texture_rect(root_node: Node, node_name: String, message: String) -> TextureRect:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is TextureRect:
		return node as TextureRect
	_failures.append("%s should be a TextureRect" % node_name)
	return null


func _assert_level_select_layout(root_node: Node) -> void:
	var mission: Control = _assert_control(root_node, "LevelMissionPanel", "level select should include the mission panel")
	var first_card: Control = _assert_control(root_node, "LevelCard1", "level select should include the first level card")
	var bottom_nav: Control = _assert_control(root_node, "BottomNav", "level select should include bottom navigation")

	if mission != null and first_card != null:
		var mission_rect: Rect2 = mission.get_global_rect()
		var first_card_rect: Rect2 = first_card.get_global_rect()
		_assert_true(mission_rect.position.y + mission_rect.size.y <= first_card_rect.position.y - 8.0, "level mission panel should not overlap the first row of level cards")

	if bottom_nav != null:
		var nav_rect: Rect2 = bottom_nav.get_global_rect()
		for level_index: int in range(1, 6):
			var card: Control = _assert_control(root_node, "LevelCard%d" % level_index, "level card %d should be a control" % level_index)
			var thumb: Control = _assert_control(root_node, "Level%dThumb" % level_index, "level %d thumbnail should be a control" % level_index)
			if card == null or thumb == null:
				continue
			_assert_true(card.clip_contents, "level card %d should clip its thumbnail art" % level_index)
			var card_rect: Rect2 = card.get_global_rect()
			var thumb_rect: Rect2 = thumb.get_global_rect()
			_assert_true(_rect_contains(card_rect, thumb_rect), "level %d thumbnail should stay inside its card" % level_index)
			_assert_true(card_rect.position.y + card_rect.size.y <= nav_rect.position.y - 16.0, "level card %d should leave room above bottom navigation" % level_index)


func _rect_contains(outer: Rect2, inner: Rect2) -> bool:
	var inner_bottom_right: Vector2 = inner.position + inner.size - Vector2(0.1, 0.1)
	return outer.has_point(inner.position) and outer.has_point(inner_bottom_right)


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
