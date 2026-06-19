extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/battle_tower_selection_guidance.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	await process_frame
	await physics_frame

	var tabby_button: Button = battle.find_child("SelectTowerTabbySlowCatButton", true, false) as Button
	if tabby_button == null:
		push_error("SelectTowerTabbySlowCatButton missing")
		quit(1)
		return
	tabby_button.emit_signal("pressed")
	for _frame: int in range(24):
		await process_frame

	var guidance: Control = battle.find_child("BattleTowerSelectionGuidance", true, false) as Control
	if guidance == null:
		push_error("BattleTowerSelectionGuidance missing")
		quit(1)
		return
	var badge: TextureRect = battle.find_child("BattleTowerSelectionGuidanceBadge", true, false) as TextureRect
	if badge == null:
		push_error("BattleTowerSelectionGuidanceBadge missing")
		quit(1)
		return
	var label: Label = battle.find_child("BattleTowerSelectionGuidanceLabel", true, false) as Label
	if label == null or not (label.text.contains("猫爪") or label.text.contains("放置")):
		push_error("BattleTowerSelectionGuidanceLabel missing expected copy")
		quit(1)
		return
	var build_button: Button = battle.find_child("BuildSlot1Button", true, false) as Button
	if build_button == null or build_button.disabled:
		push_error("BuildSlot1Button should remain tappable while tower selection guidance is visible")
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
