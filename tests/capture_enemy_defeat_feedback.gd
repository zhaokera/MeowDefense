extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/enemy_defeat_feedback.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var enemy: Node2D = EnemyScript.new()
	enemy.set("reward", 7)
	enemy.global_position = Vector2(586, 336)
	battle.enemies.append(enemy)
	var enemy_layer: Node = battle.get_node_or_null("World/Enemies")
	if enemy_layer == null:
		push_error("World/Enemies missing")
		quit(1)
		return
	enemy_layer.add_child(enemy)

	battle.call("_on_enemy_defeated", enemy)
	for i: int in range(5):
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
