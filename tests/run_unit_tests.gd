extends SceneTree

var _failures: Array[String] = []
var LevelData: GDScript
var TowerStats: GDScript
var Enemy: GDScript
var Tower: GDScript


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if _load_scripts():
		_test_level_config_loads()
		_test_enemy_moves_along_path()
		_test_tower_targets_enemy_in_range()
		_test_tower_damage_can_defeat_enemy()

	if _failures.is_empty():
		print("UNIT TESTS PASS")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		print("UNIT TESTS FAIL: %d" % _failures.size())
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s expected=%s actual=%s" % [message, str(expected), str(actual)])


func _load_scripts() -> bool:
	LevelData = load("res://scripts/core/level_data.gd")
	TowerStats = load("res://scripts/core/tower_stats.gd")
	Enemy = load("res://scripts/battle/enemy.gd")
	Tower = load("res://scripts/battle/tower.gd")
	var ok: bool = true
	var entries: Array = [
		["LevelData", LevelData],
		["TowerStats", TowerStats],
		["Enemy", Enemy],
		["Tower", Tower]
	]
	for entry: Array in entries:
		if entry[1] == null:
			_failures.append("missing script: %s" % entry[0])
			ok = false
	return ok


func _test_level_config_loads() -> void:
	var level: Resource = LevelData.new()
	level.load_from_file("res://data/levels/level_001.json")
	_assert_eq(level.id, 1, "level id")
	_assert_eq(level.name, "鱼干小路", "level name")
	_assert_eq(level.base_hp, 12, "base hp")
	_assert_eq(level.start_coins, 165, "start coins")
	_assert_eq(level.path_points.size(), 7, "path point count")
	_assert_eq(level.build_slots.size(), 5, "build slot count")
	_assert_true(level.waves.size() >= 3, "wave count")


func _test_enemy_moves_along_path() -> void:
	var enemy: Node2D = Enemy.new()
	enemy.configure({
		"id": "test_mouse",
		"max_hp": 10,
		"speed": 120.0,
		"reward": 4,
		"texture": ""
	}, [Vector2(0, 0), Vector2(100, 0), Vector2(100, 100)])
	root.add_child(enemy)

	for _i in range(80):
		enemy.advance_along_path(0.05)

	_assert_true(enemy.reached_base, "enemy should reach base after enough simulated time")
	_assert_true(enemy.global_position.distance_to(Vector2(100, 100)) < 2.0, "enemy should end near final path point")
	enemy.queue_free()


func _test_tower_targets_enemy_in_range() -> void:
	var stats: Dictionary = TowerStats.get_tower("orange_cat")
	var tower: Node2D = Tower.new()
	tower.configure("orange_cat", stats)
	tower.global_position = Vector2(50, 50)
	root.add_child(tower)

	var near_enemy: Node2D = Enemy.new()
	near_enemy.configure({
		"id": "near_mouse",
		"max_hp": 10,
		"speed": 60.0,
		"reward": 4,
		"texture": ""
	}, [Vector2(90, 50), Vector2(120, 50)])
	root.add_child(near_enemy)

	var far_enemy: Node2D = Enemy.new()
	far_enemy.configure({
		"id": "far_mouse",
		"max_hp": 10,
		"speed": 60.0,
		"reward": 4,
		"texture": ""
	}, [Vector2(500, 500), Vector2(540, 500)])
	root.add_child(far_enemy)

	var target: Node2D = tower.find_target([far_enemy, near_enemy])
	_assert_true(target == near_enemy, "tower should pick an enemy within range")
	tower.queue_free()
	near_enemy.queue_free()
	far_enemy.queue_free()


func _test_tower_damage_can_defeat_enemy() -> void:
	var stats: Dictionary = TowerStats.get_tower("orange_cat")
	var tower: Node2D = Tower.new()
	tower.configure("orange_cat", stats)
	root.add_child(tower)

	var enemy: Node2D = Enemy.new()
	enemy.configure({
		"id": "fragile_mouse",
		"max_hp": int(stats.damage),
		"speed": 60.0,
		"reward": 4,
		"texture": ""
	}, [Vector2(0, 0), Vector2(10, 0)])
	root.add_child(enemy)

	tower.apply_damage_to(enemy)
	_assert_true(enemy.is_defeated(), "enemy should be defeated by matching tower damage")
	tower.queue_free()
	enemy.queue_free()
