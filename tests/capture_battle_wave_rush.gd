extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/battle_wave_rush_feedback.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var rush_button: Button = battle.find_child("RushNextWaveButton", true, false) as Button
	if rush_button == null:
		push_error("RushNextWaveButton missing")
		quit(1)
		return
	rush_button.emit_signal("pressed")
	for i: int in range(8):
		await process_frame

	var feedback: TextureRect = battle.find_child("BattleWaveRushFeedback1", true, false) as TextureRect
	if feedback == null:
		push_error("BattleWaveRushFeedback1 missing after rushing wave")
		quit(1)
		return
	if battle.enemies.is_empty():
		push_error("rushing wave did not spawn an enemy before capture")
		quit(1)
		return

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
