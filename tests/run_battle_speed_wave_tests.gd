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

	_assert_texture_node(
		battle,
		"WavePreviewFrame",
		"res://assets/generated/ui/battle_wave_preview_chip.png",
		"wave preview should use an Image2 chip asset"
	)
	var preview_label: Label = _assert_label(battle, "WavePreviewLabel", "battle HUD should show the next wave preview")
	if preview_label != null:
		_assert_true(preview_label.text.contains("下一波"), "wave preview should explain the next incoming wave")
		_assert_true(preview_label.text.contains("偷鱼干小鼠"), "wave preview should name the next enemy")

	_assert_texture_node(
		battle,
		"SpeedControlFrame",
		"res://assets/generated/ui/battle_speed_button.png",
		"speed control should use an Image2 button asset"
	)
	var speed_label: Label = _assert_label(battle, "SpeedMultiplierLabel", "speed control should expose the current multiplier")
	if speed_label != null:
		_assert_true(speed_label.text == "1x", "battle should start at normal speed")
	var speed_button: Button = _assert_button(battle, "SpeedToggleButton", "battle HUD should expose speed toggle input")
	if speed_button != null:
		speed_button.emit_signal("pressed")
		await process_frame
		_assert_true(float(battle.get("_battle_speed_multiplier")) == 2.0, "pressing speed should switch to 2x")
		if speed_label != null:
			_assert_true(speed_label.text == "2x", "speed label should update to 2x")
		var before_elapsed: float = float(battle.elapsed)
		battle.call("_process", 0.25)
		_assert_true(float(battle.elapsed) >= before_elapsed + 0.49, "2x speed should double process-time simulation")

	if preview_label != null:
		var text_before: String = preview_label.text
		battle.simulate_step(0.5)
		await process_frame
		_assert_true(preview_label.text != text_before, "wave preview should update as the wave state changes")

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


func _assert_label(root_node: Node, node_name: String, message: String) -> Label:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Label:
		return node as Label
	_failures.append("%s should be a Label" % node_name)
	return null


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
		print("BATTLE SPEED WAVE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE SPEED WAVE TESTS FAIL: %d" % _failures.size())
		quit(1)
