extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

const OUT_DIR := "/Users/zhaok/cat/artifacts"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	if not await _capture_tower_action_exit():
		return
	if not await _capture_pause_settings_exit():
		return
	if not await _capture_pause_menu_exit():
		return
	quit(0)


func _capture_tower_action_exit() -> bool:
	var battle: Node2D = await _new_battle()
	var build_button: Button = battle.find_child("BuildSlot1Button", true, false) as Button
	if build_button == null:
		return _fail("BuildSlot1Button missing", battle)
	build_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	build_button = battle.find_child("BuildSlot1Button", true, false) as Button
	if build_button == null:
		return _fail("occupied BuildSlot1Button missing", battle)
	build_button.emit_signal("pressed")
	await process_frame
	var ok: bool = await _capture_overlay_exit(
		battle,
		"TowerActionOverlay",
		"CloseTowerActionButton",
		"tower_action_exit_animation.png"
	)
	_finish_battle(battle)
	return ok


func _capture_pause_settings_exit() -> bool:
	var battle: Node2D = await _new_battle()
	var pause_button: Button = battle.find_child("PauseButton", true, false) as Button
	if pause_button == null:
		return _fail("PauseButton missing", battle)
	pause_button.emit_signal("pressed")
	await process_frame
	var settings_button: Button = battle.find_child("PauseSettingsButton", true, false) as Button
	if settings_button == null:
		return _fail("PauseSettingsButton missing", battle)
	settings_button.emit_signal("pressed")
	await process_frame
	var ok: bool = await _capture_overlay_exit(
		battle,
		"PauseSettingsOverlay",
		"ClosePauseSettingsButton",
		"pause_settings_exit_animation.png"
	)
	_finish_battle(battle)
	return ok


func _capture_pause_menu_exit() -> bool:
	var battle: Node2D = await _new_battle()
	var pause_button: Button = battle.find_child("PauseButton", true, false) as Button
	if pause_button == null:
		return _fail("PauseButton missing", battle)
	pause_button.emit_signal("pressed")
	await process_frame
	var ok: bool = await _capture_overlay_exit(
		battle,
		"PauseMenuOverlay",
		"ResumeButton",
		"pause_menu_exit_animation.png"
	)
	_finish_battle(battle)
	return ok


func _capture_overlay_exit(battle: Node, overlay_name: String, button_name: String, file_name: String) -> bool:
	var overlay: Control = battle.find_child(overlay_name, true, false) as Control
	var button: Button = battle.find_child(button_name, true, false) as Button
	if overlay == null or button == null:
		return _fail("%s or %s missing" % [overlay_name, button_name], battle)
	for _frame: int in range(12):
		await process_frame

	Engine.time_scale = 0.04
	button.emit_signal("pressed")
	await process_frame
	if not bool(overlay.get_meta("image2_overlay_exit_animation", false)):
		return _fail("%s should mark Image2 exit animation" % overlay_name, battle)
	if not is_instance_valid(overlay):
		return _fail("%s should remain visible during slowed exit animation" % overlay_name, battle)
	await RenderingServer.frame_post_draw

	var image: Image = root.get_texture().get_image()
	if image == null:
		return _fail("failed to read viewport image", battle)
	var output_path := "%s/%s" % [OUT_DIR, file_name]
	var error: Error = image.save_png(output_path)
	if error != OK:
		return _fail("failed to save %s: %s" % [output_path, error], battle)
	print("CAPTURED %s" % output_path)
	Engine.time_scale = 1.0
	paused = false
	if is_instance_valid(overlay):
		overlay.queue_free()
	await process_frame
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
