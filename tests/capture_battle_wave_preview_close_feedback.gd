extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/battle_wave_preview_close_feedback.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	battle.set_process(false)
	await process_frame
	await physics_frame

	var info_button: Button = battle.find_child("WavePreviewInfoButton", true, false) as Button
	if info_button == null:
		push_error("WavePreviewInfoButton missing")
		quit(1)
		return
	info_button.emit_signal("pressed")
	await process_frame
	await process_frame

	var close_button: Button = battle.find_child("CloseWavePreviewDetailButton", true, false) as Button
	if close_button == null:
		push_error("CloseWavePreviewDetailButton missing")
		quit(1)
		return
	close_button.emit_signal("pressed")
	for _frame: int in range(22):
		await process_frame
	await RenderingServer.frame_post_draw

	var feedback: TextureRect = battle.find_child("WavePreviewCloseFeedback", true, false) as TextureRect
	if feedback == null:
		push_error("WavePreviewCloseFeedback missing")
		quit(1)
		return
	var label: Label = battle.find_child("WavePreviewCloseFeedbackLabel", true, false) as Label
	if label == null or not label.text.contains("情报收起"):
		push_error("WavePreviewCloseFeedbackLabel missing expected copy")
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
