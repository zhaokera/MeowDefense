extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_energy_flow_test_save.json"

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

	var first_day: Node = _new_instance(scene, "2026-06-15")
	await process_frame
	first_day.set("_energy", 1)
	first_day.set("_max_energy", 15)
	_assert_true(_as_int(first_day.get("_energy")) == 1, "test setup should be able to set current energy")
	_assert_true(_as_int(first_day.get("_max_energy")) == 15, "test setup should be able to set max energy")
	first_day.call("_show_level_select_now")
	await process_frame
	var start_level: Button = _assert_button(first_day, "StartLevel1Button", "level one should be selectable")
	if start_level != null:
		start_level.emit_signal("pressed")
		await process_frame
	_assert_exists(first_day, "BattleScene", "starting a level with energy should enter battle")
	_assert_true(_as_int(first_day.get("_energy")) == 0, "starting a level should consume one energy")

	first_day.call("_show_level_select_now")
	await process_frame
	start_level = _assert_button(first_day, "StartLevel1Button", "level one should remain visible after returning")
	if start_level != null:
		start_level.emit_signal("pressed")
		await process_frame
	_assert_missing(first_day, "BattleScene", "starting with zero energy should not enter battle")
	_assert_exists(first_day, "EnergyEmptyOverlay", "zero energy should show a dedicated feedback overlay")
	_assert_texture_node(
		first_day,
		"EnergyEmptyDesignBackground",
		"res://assets/generated/ui/energy_empty_overlay_design_reference.png",
		"zero energy feedback should render from an Image2 design asset"
	)
	_assert_true(_as_int(first_day.get("_energy")) == 0, "blocked start should not change energy")

	first_day.queue_free()
	await process_frame

	var same_day_reload: Node = _new_instance(scene, "2026-06-15")
	await process_frame
	_assert_true(_as_int(same_day_reload.get("_energy")) == 0, "same day reload should preserve spent energy")
	same_day_reload.queue_free()
	await process_frame

	var next_day_reload: Node = _new_instance(scene, "2026-06-16")
	await process_frame
	_assert_true(_as_int(next_day_reload.get("_energy")) == 15, "next day reload should refill energy to max")
	next_day_reload.queue_free()
	_finish()


func _new_instance(scene: PackedScene, date_key: String) -> Node:
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	instance.set("_reward_date_override", date_key)
	root.add_child(instance)
	return instance


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


func _as_int(value: Variant) -> int:
	if value is int or value is float:
		return int(value)
	return 0


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
		print("ENERGY FLOW TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ENERGY FLOW TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear energy flow test save: %s" % error)
