extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const WAVE_CLEAR_REFERENCE_PATH := "res://assets/generated/ui/battle_wave_clear_feedback_design_reference.png"
const WAVE_CLEAR_SOURCE_PATH := "res://assets/generated/ui/battle_wave_clear_burst_source.png"
const WAVE_CLEAR_BURST_PATH := "res://assets/generated/ui/battle_wave_clear_burst.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	_assert_true(FileAccess.file_exists(WAVE_CLEAR_REFERENCE_PATH), "wave clear should keep an Image2 full-screen battle reference")
	_assert_true(FileAccess.file_exists(WAVE_CLEAR_SOURCE_PATH), "wave clear should keep the Image2 source burst")
	_assert_true(FileAccess.file_exists(WAVE_CLEAR_BURST_PATH), "wave clear should use a project-bound transparent Image2 burst")
	_assert_manifest_entry("battle_wave_clear_feedback_design_reference", WAVE_CLEAR_REFERENCE_PATH)
	_assert_manifest_entry("battle_wave_clear_burst_source", WAVE_CLEAR_SOURCE_PATH)
	_assert_manifest_entry("battle_wave_clear_burst", WAVE_CLEAR_BURST_PATH)

	_prepare_two_enemy_first_wave(battle)
	battle.call("_spawn_due_enemies")
	battle.call("_spawn_due_enemies")
	await process_frame

	_assert_true(int(battle.enemies.size()) == 2, "test setup should spawn two enemies from wave one")
	if int(battle.enemies.size()) < 2:
		battle.queue_free()
		_finish()
		return

	var first_enemy: Node2D = battle.enemies[0] as Node2D
	battle.call("_on_enemy_defeated", first_enemy)
	await process_frame
	await physics_frame
	_assert_missing(battle, "BattleWaveClearFeedback1", "wave clear feedback should wait for the last enemy in the wave")

	var final_enemy: Node2D = battle.enemies[0] as Node2D
	battle.call("_on_enemy_defeated", final_enemy)
	await process_frame
	await physics_frame
	await process_frame

	var feedback: TextureRect = _assert_texture_node(
		battle,
		"BattleWaveClearFeedback1",
		WAVE_CLEAR_BURST_PATH,
		"clearing the last enemy in a wave should show an Image2 wave-clear burst"
	) as TextureRect
	if feedback != null:
		_assert_true(feedback.z_index > 0, "wave clear feedback should render above the battle HUD")
	var label: Label = _assert_label(battle, "BattleWaveClearFeedbackLabel", "wave clear feedback should include dynamic wave text")
	if label != null:
		_assert_true(label.text.contains("第 1/3 波"), "wave clear feedback should identify the cleared wave")
		_assert_true(label.text.contains("清理完成"), "wave clear feedback should explain that the wave is cleared")
	var tip_label: Label = _assert_label(battle, "BuildTipLabel", "battle should keep bottom guidance text")
	if tip_label != null:
		_assert_true(tip_label.text.contains("第 1 波清理完成"), "clearing a wave should update the bottom guidance")

	battle.queue_free()
	_finish()


func _prepare_two_enemy_first_wave(battle: Node) -> void:
	var wave_states: Array = battle.get("_wave_states") as Array
	for i: int in range(wave_states.size()):
		var state: Dictionary = wave_states[i] as Dictionary
		if int(state.get("index", i + 1)) == 1:
			state["remaining"] = 2
			state["total_count"] = 2
			state["start_time"] = 0.0
			state["next_time"] = 0.0
			state["interval"] = 0.0
		else:
			state["start_time"] = 999.0
			state["next_time"] = 999.0
	battle.set("elapsed", 0.0)


func _assert_texture_node(root_node: Node, node_name: String, expected_path: String, message: String) -> Node:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if not node is TextureRect and not node is Sprite2D:
		_failures.append("%s should be a TextureRect or Sprite2D" % node_name)
		return null
	var texture: Texture2D = null
	if node is TextureRect:
		texture = (node as TextureRect).texture
	elif node is Sprite2D:
		texture = (node as Sprite2D).texture
	_assert_true(texture != null, "%s should have a texture" % node_name)
	if texture != null:
		_assert_true(texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])
	return node


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
	var node: Node = _find_by_name(root_node, node_name)
	if node != null:
		_failures.append(message)


func _assert_manifest_entry(id: String, expected_path: String) -> void:
	var manifest_file: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if manifest_file == null:
		_failures.append("asset manifest should be readable")
		return
	var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
	if not (parsed is Dictionary):
		_failures.append("asset manifest should parse as a dictionary")
		return
	var ui_items: Array = (parsed as Dictionary).get("ui", []) as Array
	for item: Variant in ui_items:
		if not (item is Dictionary):
			continue
		var entry: Dictionary = item as Dictionary
		if str(entry.get("id", "")) == id:
			_assert_true(str(entry.get("path", "")) == expected_path, "%s should point to %s" % [id, expected_path])
			return
	_failures.append("asset manifest should include %s" % id)


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
		print("BATTLE WAVE CLEAR FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE WAVE CLEAR FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
