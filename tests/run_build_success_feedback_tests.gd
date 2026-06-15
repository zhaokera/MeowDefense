extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const BUILD_SUCCESS_ASSET_PATH := "res://assets/generated/effects/build_success_cat_paw_puff.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var before_towers: int = int(battle.towers.size())
	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "battle should expose the first build slot button")
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	_assert_true(int(battle.towers.size()) == before_towers + 1, "pressing a build slot should create a tower")
	_assert_build_success_feedback(battle, "successful tower construction should show Image2 build feedback")

	battle.queue_free()
	_finish()


func _assert_build_success_feedback(battle: Node, message: String) -> void:
	var node: Node = _assert_exists(battle, "BuildSuccessFeedback1", message)
	if node == null:
		return
	if not node is Sprite2D and not node is TextureRect:
		_failures.append("BuildSuccessFeedback1 should be a Sprite2D or TextureRect")
		return
	var texture: Texture2D = null
	if node is Sprite2D:
		texture = (node as Sprite2D).texture
	elif node is TextureRect:
		texture = (node as TextureRect).texture
	_assert_true(texture != null, "BuildSuccessFeedback1 should have a texture")
	if texture != null:
		_assert_true(texture.resource_path == BUILD_SUCCESS_ASSET_PATH, "BuildSuccessFeedback1 should use %s" % BUILD_SUCCESS_ASSET_PATH)


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
		print("BUILD SUCCESS FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BUILD SUCCESS FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
