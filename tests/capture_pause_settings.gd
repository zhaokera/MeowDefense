extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/pause_settings.png"


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
