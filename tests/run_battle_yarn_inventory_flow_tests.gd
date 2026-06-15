extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_battle_yarn_inventory_flow_save.json"

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

	instance.set("_yarn_traps", 1)
	instance.call("_start_level_one")
	await process_frame
	await physics_frame
	var battle: Node = instance.find_child("BattleScene", true, false)
	_assert_true(battle != null, "starting a level should create a battle scene")
	if battle == null:
		_finish()
		return
	_assert_true(_int_property(battle, "yarn_traps_available") == 1, "battle should receive yarn trap inventory from the main save state")
	battle.call("simulate_step", 0.6)
	await process_frame
	var trap_button: Button = _assert_button(battle, "UseYarnTrapButton", "battle should expose yarn trap button from inventory")
	if trap_button != null:
		trap_button.emit_signal("pressed")
		await process_frame

	_assert_true(_int_property(instance, "_yarn_traps") == 0, "using yarn trap in battle should write inventory back to main state")
	instance.queue_free()
	await process_frame

	var reloaded: Node = scene.instantiate()
	reloaded.set("_save_path", TEST_SAVE_PATH)
	root.add_child(reloaded)
	await process_frame
	_assert_true(_int_property(reloaded, "_yarn_traps") == 0, "battle yarn trap consumption should persist in save data")
	reloaded.queue_free()
	_finish()


func _int_property(instance: Node, property_name: String) -> int:
	var raw: Variant = instance.get(property_name)
	if raw == null:
		return 0
	return int(raw)


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
	_clear_save_file()
	if _failures.is_empty():
		print("BATTLE YARN INVENTORY FLOW TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE YARN INVENTORY FLOW TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear battle yarn inventory test save: %s" % error)
