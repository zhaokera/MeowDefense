extends SceneTree

const EnemyScript := preload("res://scripts/battle/enemy.gd")
const LevelBackgroundTexture := preload("res://assets/generated/backgrounds/level_001_meadow.png")
const OUT_PATH := "/Users/zhaok/cat/artifacts/enemy_fallback_asset.png"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var root_node := Node2D.new()
	root.add_child(root_node)

	var backdrop := Sprite2D.new()
	backdrop.name = "FallbackEnemyBackdrop"
	backdrop.texture = LevelBackgroundTexture
	backdrop.centered = true
	backdrop.position = Vector2(640, 360)
	var texture_size: Vector2 = LevelBackgroundTexture.get_size()
	if texture_size.x > 0.0 and texture_size.y > 0.0:
		var ratio: float = max(1280.0 / texture_size.x, 720.0 / texture_size.y)
		backdrop.scale = Vector2(ratio, ratio)
	root_node.add_child(backdrop)

	var enemy: Node2D = EnemyScript.new()
	enemy.global_position = Vector2(640, 360)
	root_node.add_child(enemy)
	enemy.configure({
		"id": "missing_mouse",
		"name": "缺图小鼠",
		"max_hp": 12,
		"speed": 70.0,
		"reward": 1,
		"damage": 1,
		"texture": "res://assets/generated/enemies/not_found.png"
	}, [Vector2(640, 360), Vector2(780, 360)])
	for i: int in range(12):
		enemy.advance_along_path(0.08)
		await process_frame

	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(OUT_PATH)
	if error != OK:
		push_error("Failed to save %s: %s" % [OUT_PATH, error])
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	root_node.queue_free()
	quit(0)
