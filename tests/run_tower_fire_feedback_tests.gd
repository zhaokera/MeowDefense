extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const TOWER_FIRE_ASSET_PATH := "res://assets/generated/effects/tower_fire_fishbone_muzzle_flash.png"
const PROJECTILE_DESIGN_PATH := "res://assets/generated/effects/tower_projectile_design_reference.png"
const PROJECTILE_ASSET_PATH := "res://assets/generated/effects/tower_fishbone_projectile.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var build_button: Button = _assert_button(battle, "BuildSlot1Button", "battle should expose the first build slot button")
	if build_button != null:
		build_button.emit_signal("pressed")
	await process_frame
	await physics_frame

	_assert_true(not battle.towers.is_empty(), "test setup should build a tower")
	var tower: Node2D = battle.towers[0] as Node2D if not battle.towers.is_empty() else null
	var enemy: Node2D = EnemyScript.new()
	enemy.set("max_hp", 20.0)
	enemy.set("hp", 20.0)
	enemy.global_position = (tower.global_position + Vector2(130, -8)) if tower != null else Vector2(300, 248)
	battle.enemies.append(enemy)
	var enemy_layer: Node = battle.get_node_or_null("World/Enemies")
	if enemy_layer != null:
		enemy_layer.add_child(enemy)
	else:
		root.add_child(enemy)

	battle.simulate_step(0.12)
	await process_frame
	await physics_frame

	_assert_true(float(enemy.get("hp")) < 20.0, "tower should damage an enemy in range")
	_assert_tower_fire_feedback(battle, "tower firing should show Image2 muzzle feedback")
	_assert_projectile(battle, "tower firing should launch a visible Image2 fishbone projectile")
	_assert_projectile_script_no_code_draw()
	_assert_manifest_entry("tower_projectile_design_reference", PROJECTILE_DESIGN_PATH)
	_assert_manifest_entry("tower_fishbone_projectile", PROJECTILE_ASSET_PATH)

	battle.queue_free()
	_finish()


func _assert_tower_fire_feedback(battle: Node, message: String) -> void:
	var node: Node = _assert_exists(battle, "TowerFireFeedback1", message)
	if node == null:
		return
	if not node is Sprite2D and not node is TextureRect:
		_failures.append("TowerFireFeedback1 should be a Sprite2D or TextureRect")
		return
	var texture: Texture2D = null
	if node is Sprite2D:
		texture = (node as Sprite2D).texture
	elif node is TextureRect:
		texture = (node as TextureRect).texture
	_assert_true(texture != null, "TowerFireFeedback1 should have a texture")
	if texture != null:
		_assert_true(texture.resource_path == TOWER_FIRE_ASSET_PATH, "TowerFireFeedback1 should use %s" % TOWER_FIRE_ASSET_PATH)


func _assert_projectile(battle: Node, message: String) -> void:
	var node: Node = _assert_exists(battle, "Image2Projectile1", message)
	if node == null:
		return
	_assert_true(node is Sprite2D, "Image2Projectile1 should be a Sprite2D using generated projectile art")
	if not node is Sprite2D:
		return
	var sprite := node as Sprite2D
	_assert_true(sprite.texture != null, "Image2Projectile1 should have a texture")
	if sprite.texture != null:
		_assert_true(sprite.texture.resource_path == PROJECTILE_ASSET_PATH, "Image2Projectile1 should use %s" % PROJECTILE_ASSET_PATH)
	_assert_true(sprite.scale.x > 0.0 and sprite.scale.y > 0.0, "Image2Projectile1 should have readable battle scale")
	_assert_true(absf(sprite.rotation) > 0.001, "Image2Projectile1 should rotate toward its target")


func _assert_projectile_script_no_code_draw() -> void:
	var file := FileAccess.open("res://scripts/battle/projectile.gd", FileAccess.READ)
	if file == null:
		_failures.append("projectile script should be readable")
		return
	var source := file.get_as_text()
	_assert_true(not source.contains("draw_circle"), "projectile should not be a code-drawn circle")
	_assert_true(source.contains("Sprite2D"), "projectile should be rendered through a sprite texture")


func _assert_manifest_entry(id: String, expected_path: String) -> void:
	var manifest_file: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if manifest_file == null:
		_failures.append("asset manifest should be readable")
		return
	var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
	if not (parsed is Dictionary):
		_failures.append("asset manifest should parse as a dictionary")
		return
	var effect_items: Array = (parsed as Dictionary).get("effects", []) as Array
	for item: Variant in effect_items:
		if not (item is Dictionary):
			continue
		var entry: Dictionary = item as Dictionary
		if str(entry.get("id", "")) == id:
			_assert_true(str(entry.get("path", "")) == expected_path, "%s should point to %s" % [id, expected_path])
			return
	_failures.append("asset manifest should include %s" % id)


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
	return null


func _assert_exists(root_node: Node, node_name: String, message: String) -> Node:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
	return node


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _finish() -> void:
	if _failures.is_empty():
		print("TOWER FIRE FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("TOWER FIRE FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
