extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

const OUT_DIR := "/Users/zhaok/cat/artifacts"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	if not await _capture_pause_action_exit("RestartBattleButton", "pause_restart_action_exit_animation.png", false):
		return
	if not await _capture_pause_action_exit("QuitToLevelsButton", "pause_quit_action_exit_animation.png", true):
		return
	quit(0)


func _capture_pause_action_exit(button_name: String, file_name: String, watch_quit_signal: bool) -> bool:
	var battle: Node2D = await _new_battle()
	var exit_state := {"requested": false}
	if watch_quit_signal:
		battle.exit_to_levels_requested.connect(func() -> void:
			exit_state["requested"] = true
		)

	var pause_button: Button = battle.find_child("PauseButton", true, false) as Button
	if pause_button == null:
		return _fail("PauseButton missing", battle)
	pause_button.emit_signal("pressed")
	await process_frame
	for _frame: int in range(12):
		await process_frame

	var overlay: Control = battle.find_child("PauseMenuOverlay", true, false) as Control
	var button: Button = battle.find_child(button_name, true, false) as Button
	if overlay == null or button == null:
		return _fail("PauseMenuOverlay or %s missing" % button_name, battle)

	Engine.time_scale = 0.04
	button.emit_signal("pressed")
	await process_frame
	if watch_quit_signal and bool(exit_state["requested"]):
		return _fail("quit signal should wait for the pause action exit animation", battle)
	if not bool(overlay.get_meta("image2_overlay_exit_animation", false)):
		return _fail("PauseMenuOverlay should mark Image2 action exit animation", battle)
	if not is_instance_valid(overlay):
		return _fail("PauseMenuOverlay should remain visible during slowed action exit animation", battle)
	await RenderingServer.frame_post_draw

	var image: Image = root.get_texture().get_image()
	if image == null:
		return _fail("failed to read viewport image", battle)
	var output_path := "%s/%s" % [OUT_DIR, file_name]
	var error: Error = image.save_png(output_path)
	if error != OK:
		return _fail("failed to save %s: %s" % [output_path, error], battle)
	print("CAPTURED %s" % output_path)
	_finish_battle(battle)
	return true


func _new_battle() -> Node2D:
	Engine.time_scale = 1.0
	paused = false
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame
	return battle


func _finish_battle(battle: Node) -> void:
	Engine.time_scale = 1.0
	paused = false
	if battle != null and is_instance_valid(battle):
		battle.queue_free()


func _fail(message: String, battle: Node) -> bool:
	push_error(message)
	_finish_battle(battle)
	quit(1)
	return false
