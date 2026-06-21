extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const BATTLE_TAP_FEEDBACK_PATH := "res://assets/generated/ui/battle_tap_feedback_starburst.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_true(FileAccess.file_exists(BATTLE_TAP_FEEDBACK_PATH), "pause settings should reuse the project-bound Image2 battle tap feedback texture")

	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var pause_button: Button = _assert_button(battle, "PauseButton", "battle HUD should expose pause")
	if pause_button != null:
		pause_button.emit_signal("pressed")
		await process_frame

	var settings_button: Button = _assert_button(battle, "PauseSettingsButton", "pause menu should expose settings")
	if settings_button != null:
		settings_button.emit_signal("pressed")
		await process_frame

	var music_toggle: CheckButton = _assert_check_button(battle, "PauseMusicToggle", "pause settings should expose a music toggle hit area")
	if music_toggle != null:
		var toggle_event := InputEventMouseButton.new()
		toggle_event.button_index = MOUSE_BUTTON_LEFT
		toggle_event.pressed = true
		toggle_event.position = Vector2(44, 30)
		music_toggle.emit_signal("gui_input", toggle_event)
		await process_frame

		var toggle_feedback: TextureRect = _find_by_name(battle, "BattleTapFeedback1") as TextureRect
		if toggle_feedback == null:
			_failures.append("pause music toggle press should spawn Image2 battle tap feedback")
		else:
			_assert_feedback(toggle_feedback, music_toggle.position + toggle_event.position, "pause music toggle")

	var volume_slider: HSlider = _assert_slider(battle, "PauseVolumeSlider", "pause settings should expose a volume slider hit area")
	if volume_slider != null:
		var slider_event := InputEventMouseButton.new()
		slider_event.button_index = MOUSE_BUTTON_LEFT
		slider_event.pressed = true
		slider_event.position = Vector2(182, 30)
		volume_slider.emit_signal("gui_input", slider_event)
		await process_frame

		var slider_feedback: TextureRect = _find_by_name(battle, "BattleTapFeedback2") as TextureRect
		if slider_feedback == null:
			_failures.append("pause volume slider press should spawn Image2 battle tap feedback")
		else:
			_assert_feedback(slider_feedback, volume_slider.position + slider_event.position, "pause volume slider")

	battle.queue_free()
	_finish()


func _assert_feedback(feedback: TextureRect, expected_center: Vector2, label: String) -> void:
	_assert_true(feedback.texture != null, "%s feedback should have a texture" % label)
	if feedback.texture != null:
		_assert_true(feedback.texture.resource_path == BATTLE_TAP_FEEDBACK_PATH, "%s feedback should use the Image2 battle tap texture" % label)
	_assert_true(feedback.mouse_filter == Control.MOUSE_FILTER_IGNORE, "%s feedback should not block pause settings input" % label)
	var actual_center: Vector2 = feedback.position + feedback.size * 0.5
	_assert_true(actual_center.distance_to(expected_center) < 1.0, "%s feedback should be centered on the pointer position" % label)


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
	return null


func _assert_check_button(root_node: Node, node_name: String, message: String) -> CheckButton:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is CheckButton:
		return node as CheckButton
	_failures.append("%s should be a CheckButton" % node_name)
	return null


func _assert_slider(root_node: Node, node_name: String, message: String) -> HSlider:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is HSlider:
		return node as HSlider
	_failures.append("%s should be an HSlider" % node_name)
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
	if _failures.is_empty():
		print("PAUSE SETTINGS CONTROL FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("PAUSE SETTINGS CONTROL FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
