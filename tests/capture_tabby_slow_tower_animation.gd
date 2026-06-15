extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")
const TowerStatsScript := preload("res://scripts/core/tower_stats.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/tabby_slow_tower_animation.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	battle.set_process(false)
	battle._wave_states.clear()
	await process_frame
	await physics_frame

	var tower_button: Button = battle.find_child("SelectTowerTabbySlowCatButton", true, false) as Button
	if tower_button == null:
		push_error("SelectTowerTabbySlowCatButton missing")
		quit(1)
		return
	tower_button.emit_signal("pressed")
	await process_frame

	var build_button: Button = battle.find_child("BuildSlot1Button", true, false) as Button
	if build_button == null:
		push_error("BuildSlot1Button missing")
		quit(1)
		return
	build_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	for i: int in range(50):
		await process_frame

	var tower: Node2D = battle.towers[0] as Node2D if not battle.towers.is_empty() else null
	if tower == null:
		push_error("Tower missing")
		quit(1)
		return
	var enemy: Node2D = EnemyScript.new()
	enemy.configure(TowerStatsScript.get_enemy("mouse_basic"), [Vector2(280, 320), Vector2(440, 320)])
	enemy.global_position = tower.global_position + Vector2(74, 0)
	battle.enemies.append(enemy)
	var enemy_layer: Node = battle.get_node_or_null("World/Enemies")
	if enemy_layer != null:
		enemy_layer.add_child(enemy)
	else:
		root.add_child(enemy)

	battle.simulate_step(0.12)
	for i: int in range(3):
		await process_frame

	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(OUT_PATH)
	if error != OK:
		push_error("Failed to save %s: %s" % [OUT_PATH, error])
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	battle.queue_free()
	quit(0)
