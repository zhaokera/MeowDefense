extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/pause_settings_control_feedback.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var pause_button: Button = battle.find_child("PauseButton", true, false) as Button
	if pause_button == null:
		push_error("PauseButton missing")
		quit(1)
		return
	pause_button.emit_signal("pressed")
	await process_frame

	var settings_button: Button = battle.find_child("PauseSettingsButton", true, false) as Button
	if settings_button == null:
		push_error("PauseSettingsButton missing")
		quit(1)
		return
	settings_button.emit_signal("pressed")
	await process_frame

	var music_toggle: CheckButton = battle.find_child("PauseMusicToggle", true, false) as CheckButton
	if music_toggle == null:
		push_error("PauseMusicToggle missing")
		quit(1)
		return
	var pointer_event := InputEventMouseButton.new()
	pointer_event.button_index = MOUSE_BUTTON_LEFT
	pointer_event.pressed = true
	pointer_event.position = music_toggle.size * 0.5
	music_toggle.emit_signal("gui_input", pointer_event)
	await process_frame

	if battle.find_child("BattleTapFeedback1", true, false) == null:
		push_error("BattleTapFeedback1 missing after pause settings toggle pointer event")
		quit(1)
		return
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
