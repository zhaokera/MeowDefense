extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/battle_build_guidance.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	for i: int in range(24):
		await process_frame

	var hint: Control = battle.find_child("BattleBuildGuidanceHint", true, false) as Control
	if hint == null:
		push_error("BattleBuildGuidanceHint missing")
		quit(1)
		return
	var badge: TextureRect = battle.find_child("BattleBuildGuidanceBadge", true, false) as TextureRect
	if badge == null:
		push_error("BattleBuildGuidanceBadge missing")
		quit(1)
		return
	var label: Label = battle.find_child("BattleBuildGuidanceLabel", true, false) as Label
	if label == null or not label.text.contains("建造"):
		push_error("BattleBuildGuidanceLabel missing expected copy")
		quit(1)
		return
	var build_button: Button = battle.find_child("BuildSlot1Button", true, false) as Button
	if build_button == null or build_button.disabled:
		push_error("BuildSlot1Button should remain tappable while guidance is visible")
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
