extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/battle_level_001.png"
const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await process_frame
	await process_frame
	var image: Image = root.get_texture().get_image()
	var result: Error = image.save_png(OUT_PATH)
	if result != OK:
		push_error("failed to save screenshot: %s" % result)
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	battle.queue_free()
	quit(0)
