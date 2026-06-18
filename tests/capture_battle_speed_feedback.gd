extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/battle_speed_feedback.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var speed_button: Button = battle.find_child("SpeedToggleButton", true, false) as Button
	if speed_button == null:
		push_error("SpeedToggleButton missing")
		quit(1)
		return
	speed_button.emit_signal("pressed")
	for i: int in range(8):
		await process_frame

	var feedback: TextureRect = battle.find_child("BattleSpeedFeedback1", true, false) as TextureRect
	if feedback == null:
		push_error("BattleSpeedFeedback1 missing after speed toggle")
		quit(1)
		return
	var label: Label = battle.find_child("BattleSpeedFeedbackLabel", true, false) as Label
	if label == null or not label.text.contains("2x"):
		push_error("BattleSpeedFeedbackLabel missing 2x state")
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
		push_error("failed to save battle speed feedback screenshot: %s" % error)
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	battle.queue_free()
	quit(0)
