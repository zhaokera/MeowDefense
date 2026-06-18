extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var pause_button: Button = _assert_button(battle, "PauseButton", "battle HUD should expose pause")
	if pause_button != null:
		pause_button.emit_signal("pressed")
		await process_frame

	_assert_exists(battle, "PauseMenuOverlay", "pause should open an overlay")
	_assert_overlay_z_index(battle, "PauseMenuOverlay", 100, "pause overlay should render above battle HUD controls")
	_assert_texture_node(
		battle,
		"PauseMenuDesignPanel",
		"res://assets/generated/ui/battle_pause_menu_panel.png",
		"pause menu should use an Image2 panel asset"
	)
	_assert_texture_node(
		battle,
		"PauseResumeFrame",
		"res://assets/generated/ui/battle_pause_button_green.png",
		"resume should use an Image2 button asset"
	)
	_assert_texture_node(
		battle,
		"PauseRestartFrame",
		"res://assets/generated/ui/battle_pause_button_orange.png",
		"restart should use an Image2 button asset"
	)
	_assert_texture_node(
		battle,
		"PauseSettingsFrame",
		"res://assets/generated/ui/battle_pause_button_blue.png",
		"settings should use an Image2 button asset"
	)
	_assert_texture_node(
		battle,
		"PauseQuitFrame",
		"res://assets/generated/ui/battle_pause_button_red.png",
		"quit should use an Image2 button asset"
	)
	_assert_missing(battle, "PausePanel", "pause menu should not render the old code-drawn panel")

	var resume_button: Button = _assert_button(battle, "ResumeButton", "pause menu should resume")
	_assert_button(battle, "RestartBattleButton", "pause menu should restart")
	var settings_button: Button = _assert_button(battle, "PauseSettingsButton", "pause menu should expose settings")
	_assert_button(battle, "QuitToLevelsButton", "pause menu should return to level select")
	if settings_button != null:
		settings_button.emit_signal("pressed")
		await process_frame
		_assert_true(not settings_button.visible, "pause menu controls should hide while pause settings is open")
		_assert_exists(battle, "PauseSettingsOverlay", "pause settings should open inside the pause overlay")
		_assert_node_is_not_panel(battle, "PauseSettingsOverlay", "pause settings overlay should not be a code-drawn Panel")
		_assert_texture_node(
			battle,
			"PauseSettingsDesignPanel",
			"res://assets/generated/ui/settings_overlay_panel.png",
			"pause settings should use an Image2 settings panel"
		)
		_assert_texture_node(
			battle,
			"PauseSettingsMusicToggleFrame",
			"res://assets/generated/ui/settings_toggle_on.png",
			"pause settings music toggle should use an Image2 toggle"
		)
		_assert_texture_node(
			battle,
			"PauseSettingsEffectsToggleFrame",
			"res://assets/generated/ui/settings_toggle_on.png",
			"pause settings effects toggle should use an Image2 toggle"
		)
		_assert_texture_node(
			battle,
			"PauseSettingsVolumeSliderFrame",
			"res://assets/generated/ui/settings_slider_track.png",
			"pause settings volume slider should use an Image2 track"
		)
		_assert_texture_node(
			battle,
			"PauseSettingsCloseFrame",
			"res://assets/generated/ui/settings_close_button.png",
			"pause settings close should use an Image2 button"
		)
		var close_settings: Button = _assert_button(battle, "ClosePauseSettingsButton", "pause settings should be closable")
		if close_settings != null:
			close_settings.emit_signal("pressed")
			await process_frame
			_assert_missing(battle, "PauseSettingsOverlay", "pause settings should close without closing pause menu")
			_assert_exists(battle, "PauseMenuOverlay", "pause menu should remain open after closing pause settings")
			_assert_true(settings_button.visible, "pause menu controls should return after closing pause settings")
	if resume_button != null:
		resume_button.emit_signal("pressed")
		await process_frame
		_assert_missing(battle, "PauseMenuOverlay", "resume should close pause menu")

	battle.queue_free()
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


func _assert_node_is_not_panel(root_node: Node, node_name: String, message: String) -> void:
	var node: Node = _find_by_name(root_node, node_name)
	if node != null and node is Panel:
		_failures.append(message)


func _assert_overlay_z_index(root_node: Node, node_name: String, min_z_index: int, message: String) -> void:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		return
	if node is CanvasItem:
		_assert_true((node as CanvasItem).z_index >= min_z_index, message)
	else:
		_failures.append("%s should be a CanvasItem" % node_name)


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
		print("PAUSE MENU TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("PAUSE MENU TESTS FAIL: %d" % _failures.size())
		quit(1)
