extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for level_index: int in range(1, 6):
		await _test_level_can_be_won(level_index)
	_finish()


func _test_level_can_be_won(level_index: int) -> void:
	var path: String = "res://data/levels/level_%03d.json" % level_index
	if not FileAccess.file_exists(path):
		_failures.append("playthrough level file should exist: %s" % path)
		return

	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level(path)
	await process_frame

	var built_slots: Dictionary = {}
	var elapsed_limit: float = 95.0
	var simulated: float = 0.0
	while simulated < elapsed_limit and not bool(battle.finished):
		_auto_build_available_slot(battle, built_slots)
		battle._process(0.1)
		await process_frame
		simulated += 0.1

	if not bool(battle.finished):
		_failures.append("level %d should finish within %.1fs" % [level_index, elapsed_limit])
	elif int(battle.base_hp) <= 0:
		_failures.append("level %d should be won by the automated playthrough" % level_index)
	else:
		var stars: int = battle._calculate_stars()
		if stars < 1:
			_failures.append("level %d should finish with at least one star" % level_index)
	battle.queue_free()


func _auto_build_available_slot(battle: Node2D, built_slots: Dictionary) -> void:
	var slot_layer: Node = battle.get_node_or_null("World/BuildSlots")
	if slot_layer == null:
		return
	for slot: Node in slot_layer.get_children():
		if built_slots.has(slot.get_instance_id()):
			continue
		if bool(slot.get("occupied")):
			built_slots[slot.get_instance_id()] = true
			continue
		var before_coins: int = int(battle.coins)
		battle._on_slot_clicked(slot)
		if int(battle.coins) < before_coins:
			built_slots[slot.get_instance_id()] = true
			return


func _finish() -> void:
	if _failures.is_empty():
		print("PLAYTHROUGH TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("PLAYTHROUGH TESTS FAIL: %d" % _failures.size())
		quit(1)
