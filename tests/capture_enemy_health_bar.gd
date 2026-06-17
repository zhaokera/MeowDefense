extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")
const TowerStatsScript := preload("res://scripts/core/tower_stats.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/enemy_health_bar.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var enemy: Node2D = EnemyScript.new()
	enemy.configure(TowerStatsScript.get_enemy("mouse_basic"), [Vector2(24, 360), Vector2(226, 360)])
	enemy.global_position = Vector2(640, 310)
	var enemy_layer: Node = battle.get_node_or_null("World/Enemies")
	if enemy_layer != null:
		enemy_layer.add_child(enemy)
	else:
		root.add_child(enemy)
	battle.enemies.append(enemy)
	enemy.take_damage(float(enemy.get("max_hp")) * 0.76)
	for i: int in range(8):
		await process_frame

	var image: Image = root.get_texture().get_image()
	if image == null:
		push_error("failed to read viewport image")
		quit(1)
		return
	var error: Error = image.save_png(OUT_PATH)
	if error != OK:
		push_error("failed to save %s: %s" % [OUT_PATH, error])
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	battle.queue_free()
	quit(0)
