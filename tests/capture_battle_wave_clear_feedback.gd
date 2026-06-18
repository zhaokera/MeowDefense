extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/battle_wave_clear_feedback.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	_prepare_two_enemy_first_wave(battle)
	battle.call("_spawn_due_enemies")
	battle.call("_spawn_due_enemies")
	await process_frame
	if int(battle.enemies.size()) < 2:
		push_error("test setup did not spawn two wave-one enemies")
		quit(1)
		return

	battle.call("_on_enemy_defeated", battle.enemies[0])
	await process_frame
	if battle.enemies.is_empty():
		push_error("first defeat removed every wave-one enemy")
		quit(1)
		return
	battle.call("_on_enemy_defeated", battle.enemies[0])
	for i: int in range(8):
		await process_frame

	var feedback: TextureRect = battle.find_child("BattleWaveClearFeedback1", true, false) as TextureRect
	if feedback == null:
		push_error("BattleWaveClearFeedback1 missing after clearing wave")
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
	var error: Error = image.save_png(OUT_PATH)
	if error != OK:
		push_error("failed to save battle wave clear feedback screenshot: %s" % error)
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	battle.queue_free()
	quit(0)


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
