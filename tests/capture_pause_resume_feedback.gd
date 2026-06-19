extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/pause_resume_feedback.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	battle.set_process(false)
	await process_frame
	await physics_frame

	var pause_button: Button = battle.find_child("PauseButton", true, false) as Button
	if pause_button == null:
		push_error("PauseButton missing")
		quit(1)
		return
	pause_button.emit_signal("pressed")
	await process_frame

	var resume_button: Button = battle.find_child("ResumeButton", true, false) as Button
	if resume_button == null:
		push_error("ResumeButton missing")
		quit(1)
		return
	resume_button.emit_signal("pressed")
	for _frame: int in range(24):
		await process_frame
	await RenderingServer.frame_post_draw

	var feedback: TextureRect = battle.find_child("PauseResumeFeedback", true, false) as TextureRect
	if feedback == null:
		push_error("PauseResumeFeedback missing")
		quit(1)
		return
	var label: Label = battle.find_child("PauseResumeFeedbackLabel", true, false) as Label
	if label == null or not label.text.contains("继续守卫"):
		push_error("PauseResumeFeedbackLabel missing expected copy")
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
	paused = false
	quit(0)
