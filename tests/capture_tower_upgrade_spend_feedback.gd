extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/tower_upgrade_spend_feedback.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	battle.set_process(false)
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
	await create_timer(0.34).timeout
	await RenderingServer.frame_post_draw

	var chip: TextureRect = battle.find_child("TowerUpgradeSpendFish1", true, false) as TextureRect
	if chip == null:
		push_error("TowerUpgradeSpendFish1 missing")
		quit(1)
		return
	var coins_label: Label = battle.find_child("CoinsLabel", true, false) as Label
	if coins_label == null or not bool(coins_label.get_meta("image2_tower_upgrade_spend_source", false)):
		push_error("CoinsLabel should be marked as tower upgrade spend source")
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
