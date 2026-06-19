extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/battle_reward_fly_feedback.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	battle.set_process(false)
	await process_frame
	await physics_frame

	var enemy: Node2D = EnemyScript.new()
	enemy.set("reward", 7)
	enemy.global_position = Vector2(530, 338)
	battle.enemies.append(enemy)
	root.add_child(enemy)
	battle.call("_on_enemy_defeated", enemy)
	await create_timer(0.50).timeout

	var chip: TextureRect = battle.find_child("BattleRewardFlyFish1", true, false) as TextureRect
	if chip == null:
		push_error("BattleRewardFlyFish1 missing")
		quit(1)
		return
	var coins_label: Label = battle.find_child("CoinsLabel", true, false) as Label
	if coins_label == null or not bool(coins_label.get_meta("image2_battle_reward_fly_target", false)):
		push_error("CoinsLabel should be marked as battle reward fly target")
		quit(1)
		return

	var viewport_texture: ViewportTexture = root.get_texture()
	if viewport_texture == null:
		push_error("failed to read viewport texture")
		quit(1)
		return
	var image: Image = viewport_texture.get_image()
	if image == null:
		push_error("failed to read viewport image")
		quit(1)
		return
	var result: Error = image.save_png(OUT_PATH)
	if result != OK:
		push_error("failed to save screenshot: %s" % result)
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	battle.queue_free()
	quit(0)
