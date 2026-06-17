extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const TEST_LEVEL_PATH := "user://meow_defense_missing_background_capture_level.json"
const OUT_PATH := "/Users/zhaok/cat/artifacts/battle_background_fallback.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	_write_test_level()
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level(TEST_LEVEL_PATH)
	await process_frame
	await physics_frame
	for i: int in range(8):
		await process_frame

	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(OUT_PATH)
	if error != OK:
		push_error("Failed to save %s: %s" % [OUT_PATH, error])
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	battle.queue_free()
	_clear_test_level()
	quit(0)


func _write_test_level() -> void:
	var data := {
		"id": 902,
		"name": "缺失背景截图",
		"description": "Fallback background capture.",
		"background": "res://assets/generated/backgrounds/missing_capture_background.png",
		"base_texture": "res://assets/generated/bases/fish_base.png",
		"base_hp": 12,
		"start_coins": 120,
		"reward_fish": 0,
		"allowed_towers": ["orange_cat"],
		"path_points": [[24, 360], [226, 360], [376, 236], [592, 236], [744, 424], [1036, 424], [1220, 312]],
		"build_slots": [[212, 248], [396, 360], [616, 344], [824, 300], [994, 516]],
		"waves": []
	}
	var file := FileAccess.open(TEST_LEVEL_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))


func _clear_test_level() -> void:
	if FileAccess.file_exists(TEST_LEVEL_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_LEVEL_PATH))
