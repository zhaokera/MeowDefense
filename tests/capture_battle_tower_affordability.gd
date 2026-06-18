extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const OUT_PATH := "/Users/zhaok/cat/artifacts/battle_tower_affordability.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	await process_frame
	await physics_frame

	battle.set("coins", 65)
	battle.call("_update_hud")
	var tabby_button: Button = battle.find_child("SelectTowerTabbySlowCatButton", true, false) as Button
	if tabby_button == null:
		push_error("SelectTowerTabbySlowCatButton missing")
		quit(1)
		return
	tabby_button.emit_signal("pressed")
	for i: int in range(16):
		await process_frame

	var shortage_stamp: TextureRect = battle.find_child("TowerCardTabbySlowCatInsufficientFishState", true, false) as TextureRect
	if shortage_stamp == null or not shortage_stamp.visible:
		push_error("tabby tower insufficient-fish stamp missing")
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
		push_error("failed to save battle tower affordability screenshot: %s" % error)
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	battle.queue_free()
	quit(0)
