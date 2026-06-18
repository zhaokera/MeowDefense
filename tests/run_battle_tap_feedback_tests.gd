extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const BATTLE_SCRIPT_PATH := "res://scripts/battle/battle_scene.gd"
const BUILD_SLOT_SCRIPT_PATH := "res://scripts/battle/build_slot.gd"
const ASSET_MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const TAP_FEEDBACK_PATH := "res://assets/generated/ui/battle_tap_feedback_starburst.png"
const TAP_FEEDBACK_SOURCE_PATH := "res://assets/generated/ui/battle_tap_feedback_starburst_source.png"
const TAP_FEEDBACK_REFERENCE_PATH := "res://assets/generated/ui/battle_tap_feedback_design_reference.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle_source := _read_text(BATTLE_SCRIPT_PATH)
	var build_slot_source := _read_text(BUILD_SLOT_SCRIPT_PATH)
	var manifest_source := _read_text(ASSET_MANIFEST_PATH)
	_assert_true(FileAccess.file_exists(TAP_FEEDBACK_PATH), "battle tap feedback should use a project-bound Image2 texture")
	_assert_true(FileAccess.file_exists(TAP_FEEDBACK_SOURCE_PATH), "battle tap feedback should keep its derived Image2 source asset")
	_assert_true(FileAccess.file_exists(TAP_FEEDBACK_REFERENCE_PATH), "battle tap feedback should keep its Image2 battle reference")
	_assert_true(manifest_source.contains("\"battle_tap_feedback_starburst\""), "manifest should list the battle tap runtime asset")
	_assert_true(manifest_source.contains("\"battle_tap_feedback_design_reference\""), "manifest should list the battle tap reference")
	_assert_true(battle_source.contains("BattleTapFeedbackTexture"), "battle HUD should preload the Image2 battle tap feedback texture")
	_assert_true(not build_slot_source.contains("func _draw("), "build slots should not retain a code-draw hook")

	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var build_button: Button = _find_by_name(battle, "BuildSlot1Button") as Button
	if build_button == null:
		_failures.append("battle should expose a build slot button")
	else:
		var pointer_event := InputEventMouseButton.new()
		pointer_event.button_index = MOUSE_BUTTON_LEFT
		pointer_event.pressed = true
		pointer_event.position = Vector2(20, 28)
		build_button.emit_signal("gui_input", pointer_event)
		await process_frame

		var feedback: TextureRect = _find_by_name(battle, "BattleTapFeedback1") as TextureRect
		if feedback == null:
			_failures.append("battle build slot press should spawn an Image2 tap feedback TextureRect")
		else:
			_assert_true(feedback.texture != null, "battle tap feedback should have a texture")
			if feedback.texture != null:
				_assert_true(feedback.texture.resource_path == TAP_FEEDBACK_PATH, "battle tap feedback should use the Image2 battle starburst")
			_assert_true(feedback.mouse_filter == Control.MOUSE_FILTER_IGNORE, "battle tap feedback should not block battle input")
			var expected_center: Vector2 = build_button.position + pointer_event.position
			var actual_center: Vector2 = feedback.position + feedback.size * 0.5
			_assert_true(actual_center.distance_to(expected_center) < 1.0, "battle tap feedback should be centered on the pointer position")

	var speed_button: Button = _find_by_name(battle, "SpeedToggleButton") as Button
	if speed_button == null:
		_failures.append("battle should expose the speed toggle button")
	else:
		var speed_event := InputEventMouseButton.new()
		speed_event.button_index = MOUSE_BUTTON_LEFT
		speed_event.pressed = true
		speed_event.position = Vector2(48, 48)
		speed_button.emit_signal("gui_input", speed_event)
		await process_frame

		var speed_feedback: TextureRect = _find_by_name(battle, "BattleTapFeedback2") as TextureRect
		if speed_feedback == null:
			_failures.append("direct CanvasLayer HUD buttons should also spawn Image2 tap feedback")
		else:
			_assert_true(speed_feedback.texture != null, "speed tap feedback should have a texture")
			if speed_feedback.texture != null:
				_assert_true(speed_feedback.texture.resource_path == TAP_FEEDBACK_PATH, "speed tap feedback should use the Image2 battle starburst")
			var feedback_parent_node: Node = speed_feedback.get_parent()
			_assert_true(feedback_parent_node is CanvasLayer and feedback_parent_node.name == "HUD", "CanvasLayer battle tap feedback should render directly under the HUD layer")
			var viewport_size: Vector2 = battle.get_viewport_rect().size
			_assert_true(speed_feedback.position.x >= 0.0 and speed_feedback.position.y >= 0.0, "edge HUD tap feedback should stay inside the viewport")
			_assert_true(speed_feedback.position.x + speed_feedback.size.x <= viewport_size.x + 1.0, "edge HUD tap feedback should not overflow the viewport horizontally")
			_assert_true(speed_feedback.position.y + speed_feedback.size.y <= viewport_size.y + 1.0, "edge HUD tap feedback should not overflow the viewport vertically")
			var expected_speed_center: Vector2 = speed_button.position + speed_event.position
			var actual_speed_center: Vector2 = speed_feedback.position + speed_feedback.size * 0.5
			_assert_true(actual_speed_center.distance_to(expected_speed_center) < 42.0, "clamped edge HUD tap feedback should stay near the pointer position")

	battle.queue_free()
	_finish()


func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_failures.append("%s should be readable" % path)
		return ""
	return file.get_as_text()


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


func _finish() -> void:
	if _failures.is_empty():
		print("BATTLE TAP FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE TAP FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
