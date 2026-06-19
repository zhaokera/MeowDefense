extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/battle_wave_preview_detail.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	await process_frame
	await process_frame

	var info_button: Button = battle.find_child("WavePreviewInfoButton", true, false) as Button
	if info_button == null:
		push_error("WavePreviewInfoButton missing")
		quit(1)
		return
	info_button.emit_signal("pressed")
	for i: int in range(24):
		await process_frame

	var overlay: Control = battle.find_child("BattleWavePreviewDetailOverlay", true, false) as Control
	if overlay == null:
		push_error("BattleWavePreviewDetailOverlay missing")
		quit(1)
		return
	var enemy_name: Label = battle.find_child("WavePreviewEnemyName", true, false) as Label
	if enemy_name == null or not enemy_name.text.contains("偷鱼干小鼠"):
		push_error("WavePreviewEnemyName missing expected copy")
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
