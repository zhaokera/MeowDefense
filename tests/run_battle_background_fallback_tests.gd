extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const TEST_LEVEL_PATH := "user://meow_defense_missing_background_level.json"
const FALLBACK_BACKGROUND_PATH := "res://assets/generated/backgrounds/level_001_meadow.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_write_test_level()
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level(TEST_LEVEL_PATH)
	await process_frame
	await physics_frame

	var background: Sprite2D = _assert_background_sprite(battle, "battle should render an Image2 fallback background when configured background is missing")
	if background != null:
		_assert_true(background.texture != null, "fallback background should have a texture")
		if background.texture != null:
			_assert_true(background.texture.resource_path == FALLBACK_BACKGROUND_PATH, "fallback background should use %s" % FALLBACK_BACKGROUND_PATH)
		_assert_true(background.z_index < 0, "fallback background should sit behind gameplay nodes")
	_assert_battle_script_no_code_background()

	battle.queue_free()
	_clear_test_level()
	_finish()


func _write_test_level() -> void:
	var data := {
		"id": 901,
		"name": "缺失背景测试",
		"description": "Fallback background test.",
		"background": "res://assets/generated/backgrounds/missing_level_background.png",
		"base_texture": "res://assets/generated/bases/fish_base.png",
		"base_hp": 12,
		"start_coins": 120,
		"reward_fish": 0,
		"allowed_towers": ["orange_cat"],
		"path_points": [[24, 360], [226, 360], [376, 236], [592, 236], [744, 424], [1036, 424], [1220, 312]],
		"build_slots": [[212, 248], [396, 360]],
		"waves": []
	}
	var file := FileAccess.open(TEST_LEVEL_PATH, FileAccess.WRITE)
	if file == null:
		_failures.append("test level file should be writable")
		return
	file.store_string(JSON.stringify(data))


func _clear_test_level() -> void:
	if FileAccess.file_exists(TEST_LEVEL_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_LEVEL_PATH))
		if error != OK:
			_failures.append("failed to clear test level file: %s" % error)


func _assert_background_sprite(root_node: Node, message: String) -> Sprite2D:
	var node: Node = _find_by_name(root_node, "BattleBackground")
	if node == null:
		_failures.append(message)
		return null
	if node is Sprite2D:
		return node as Sprite2D
	_failures.append("BattleBackground should be a Sprite2D")
	return null


func _assert_battle_script_no_code_background() -> void:
	var file := FileAccess.open("res://scripts/battle/battle_scene.gd", FileAccess.READ)
	if file == null:
		_failures.append("battle scene script should be readable")
		return
	var source := file.get_as_text()
	_assert_true(not source.contains("draw_rect"), "battle background should not fall back to a code-drawn rectangle")
	_assert_true(not source.contains("draw_line"), "battle path should not fall back to code-drawn lines")
	_assert_true(not source.contains("draw_circle"), "battle goal should not fall back to code-drawn circles")


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
		print("BATTLE BACKGROUND FALLBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE BACKGROUND FALLBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
