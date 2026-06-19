extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/tower_action_cancel_feedback.png"


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

	build_button = battle.find_child("BuildSlot1Button", true, false) as Button
	if build_button == null:
		push_error("occupied BuildSlot1Button missing")
		quit(1)
		return
	build_button.emit_signal("pressed")
	await process_frame

	var close_button: Button = battle.find_child("CloseTowerActionButton", true, false) as Button
	if close_button == null:
		push_error("CloseTowerActionButton missing")
		quit(1)
		return
	close_button.emit_signal("pressed")
	await process_frame
	for _frame: int in range(8):
		await process_frame

	var feedback: TextureRect = battle.find_child("TowerActionCancelFeedback", true, false) as TextureRect
	if feedback == null:
		push_error("TowerActionCancelFeedback missing")
		quit(1)
		return

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
