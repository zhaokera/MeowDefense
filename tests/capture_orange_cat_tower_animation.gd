extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/orange_cat_tower_animation.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	battle.set_process(false)
	await process_frame
	await physics_frame

	var build_button: Button = battle.find_child("BuildSlot1Button", true, false) as Button
	if build_button == null:
		push_error("BuildSlot1Button missing")
		quit(1)
		return
	build_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	for i: int in range(100):
		await process_frame

	var tower: Node2D = battle.towers[0] as Node2D if not battle.towers.is_empty() else null
	if tower == null:
		push_error("Tower missing")
		quit(1)
		return
	var enemy: Node2D = EnemyScript.new()
	enemy.set("max_hp", 20.0)
	enemy.set("hp", 20.0)
	enemy.global_position = tower.global_position + Vector2(68, -8)
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
