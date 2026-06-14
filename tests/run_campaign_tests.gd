extends SceneTree

const LevelDataScript := preload("res://scripts/core/level_data.gd")
const TowerStatsScript := preload("res://scripts/core/tower_stats.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")
const TowerScript := preload("res://scripts/battle/tower.gd")
const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_five_levels_are_configured()
	_test_assets_are_categorized_and_manifested()
	await _test_units_expose_animation_support()
	_finish()


func _test_five_levels_are_configured() -> void:
	var seen_ids: Dictionary = {}
	for level_index: int in range(1, 6):
		var path: String = "res://data/levels/level_%03d.json" % level_index
		_assert_true(FileAccess.file_exists(path), "level file should exist: %s" % path)
		if not FileAccess.file_exists(path):
			continue

		var level: Resource = LevelDataScript.new()
		level.load_from_file(path)
		_assert_true(level.id == level_index, "level %d should have matching id" % level_index)
		_assert_true(not seen_ids.has(level.id), "level id should be unique: %d" % level.id)
		seen_ids[level.id] = true
		_assert_true(not level.name.is_empty(), "level %d should have a name" % level_index)
		_assert_true(level.path_points.size() >= 6, "level %d should have at least 6 path points" % level_index)
		_assert_true(level.build_slots.size() >= 5, "level %d should have at least 5 build slots" % level_index)
		_assert_true(level.waves.size() >= 3, "level %d should have at least 3 waves" % level_index)
		_assert_true(ResourceLoader.exists(level.background), "level %d background should exist: %s" % [level_index, level.background])
		_assert_true(ResourceLoader.exists(level.base_texture), "level %d base texture should exist: %s" % [level_index, level.base_texture])
		for tower_id: String in level.allowed_towers:
			_assert_true(not TowerStatsScript.get_tower(tower_id).is_empty(), "level %d tower id should be valid: %s" % [level_index, tower_id])
		for wave: Dictionary in level.waves:
			var enemy_id: String = str(wave.get("enemy", ""))
			_assert_true(not TowerStatsScript.get_enemy(enemy_id).is_empty(), "level %d wave enemy should be valid: %s" % [level_index, enemy_id])


func _test_assets_are_categorized_and_manifested() -> void:
	var required_dirs: Array[String] = [
		"res://assets/generated/backgrounds",
		"res://assets/generated/towers",
		"res://assets/generated/enemies",
		"res://assets/generated/bases",
		"res://assets/generated/ui"
	]
	for dir_path: String in required_dirs:
		_assert_true(DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir_path)), "asset directory should exist: %s" % dir_path)

	var manifest_path: String = "res://assets/generated/assets_manifest.json"
	_assert_true(FileAccess.file_exists(manifest_path), "asset manifest should exist")
	if not FileAccess.file_exists(manifest_path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	_assert_true(parsed is Dictionary, "asset manifest should be a JSON object")
	if not (parsed is Dictionary):
		return
	var manifest: Dictionary = parsed as Dictionary
	for category: String in ["backgrounds", "towers", "enemies", "bases", "ui"]:
		_assert_true(manifest.has(category), "manifest should include category: %s" % category)
		_assert_true(manifest.get(category, []) is Array, "manifest category should be an array: %s" % category)
		_assert_true((manifest.get(category, []) as Array).size() > 0, "manifest category should not be empty: %s" % category)


func _test_units_expose_animation_support() -> void:
	for enemy_id: String in TowerStatsScript.ENEMIES.keys():
		var enemy: Node2D = EnemyScript.new()
		enemy.configure(TowerStatsScript.get_enemy(enemy_id), [Vector2(0, 0), Vector2(80, 0)])
		root.add_child(enemy)
		await process_frame
		_assert_true(enemy.has_method("has_animation_support"), "enemy %s should expose animation support query" % enemy_id)
		if enemy.has_method("has_animation_support"):
			_assert_true(enemy.call("has_animation_support"), "enemy %s animation support should be active" % enemy_id)
		enemy.queue_free()

	for tower_id: String in TowerStatsScript.TOWERS.keys():
		var tower: Node2D = TowerScript.new()
		tower.configure(tower_id, TowerStatsScript.get_tower(tower_id))
		root.add_child(tower)
		await process_frame
		_assert_true(tower.has_method("has_animation_support"), "tower %s should expose animation support query" % tower_id)
		if tower.has_method("has_animation_support"):
			_assert_true(tower.call("has_animation_support"), "tower %s animation support should be active" % tower_id)
		tower.queue_free()

	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	_assert_true(battle.has_method("has_base_animation_support"), "battle scene should expose base animation support query")
	if battle.has_method("has_base_animation_support"):
		_assert_true(battle.call("has_base_animation_support"), "base animation support should be active")
	battle.queue_free()


func _finish() -> void:
	if _failures.is_empty():
		print("CAMPAIGN TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("CAMPAIGN TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
