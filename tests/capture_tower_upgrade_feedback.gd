extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/tower_upgrade_feedback.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var build_button: Button = battle.find_child("BuildSlot1Button", true, false) as Button
	if build_button == null:
		push_error("BuildSlot1Button missing")
		quit(1)
		return
	build_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	build_button.emit_signal("pressed")
	await process_frame
	var upgrade_button: Button = battle.find_child("UpgradeTowerButton", true, false) as Button
	if upgrade_button == null:
		push_error("UpgradeTowerButton missing")
		quit(1)
		return
	upgrade_button.emit_signal("pressed")
	for i: int in range(6):
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
