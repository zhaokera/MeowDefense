extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

const OUT_PATH := "/Users/zhaok/cat/artifacts/tower_sell_action_exit_animation.png"


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
		_fail("BuildSlot1Button missing", battle)
		return
	build_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	build_button = battle.find_child("BuildSlot1Button", true, false) as Button
	if build_button == null:
		_fail("occupied BuildSlot1Button missing", battle)
		return
	build_button.emit_signal("pressed")
	await process_frame
	for _frame: int in range(12):
		await process_frame

	var overlay: Control = battle.find_child("TowerActionOverlay", true, false) as Control
	var sell_button: Button = battle.find_child("SellTowerButton", true, false) as Button
	if overlay == null or sell_button == null:
		_fail("TowerActionOverlay or SellTowerButton missing", battle)
		return

	Engine.time_scale = 0.04
	sell_button.emit_signal("pressed")
	await process_frame
	if not bool(overlay.get_meta("image2_overlay_exit_animation", false)):
		_fail("TowerActionOverlay should mark Image2 sell exit animation", battle)
		return
	if not is_instance_valid(overlay):
		_fail("TowerActionOverlay should remain visible during slowed sell exit animation", battle)
		return
	if int(battle.towers.size()) != 0:
		_fail("tower should be sold before capturing sell action exit", battle)
		return
	await RenderingServer.frame_post_draw

	var image: Image = root.get_texture().get_image()
	if image == null:
		_fail("failed to read viewport image", battle)
		return
	var error: Error = image.save_png(OUT_PATH)
	if error != OK:
		_fail("failed to save %s: %s" % [OUT_PATH, error], battle)
		return
	print("CAPTURED %s" % OUT_PATH)
	Engine.time_scale = 1.0
	battle.queue_free()
	quit(0)


func _fail(message: String, battle: Node) -> void:
	push_error(message)
	Engine.time_scale = 1.0
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	quit(1)
