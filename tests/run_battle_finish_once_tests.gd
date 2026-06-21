extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_001.json")
	await process_frame
	await physics_frame

	var emitted_results: Array[Dictionary] = []
	battle.battle_finished.connect(func(won: bool, stars: int, fish_reward: int) -> void:
		emitted_results.append({
			"won": won,
			"stars": stars,
			"fish_reward": fish_reward
		})
	)

	battle.call("_finish", true)
	battle.call("_finish", true)
	battle.call("_finish", false)
	await process_frame

	_assert_true(emitted_results.size() == 1, "battle should emit one final result even if finish is triggered repeatedly")
	if emitted_results.size() > 0:
		var first: Dictionary = emitted_results[0]
		_assert_true(bool(first.get("won", false)), "the first finish result should be preserved")
		_assert_true(int(first.get("stars", 0)) > 0, "the first finish result should keep its stars")
		_assert_true(int(first.get("fish_reward", 0)) > 0, "the first finish result should keep its victory reward")
	_assert_true(bool(battle.get("finished")), "battle should remain marked finished after the first result")

	battle.queue_free()
	_finish()


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("BATTLE FINISH ONCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE FINISH ONCE TESTS FAIL: %d" % _failures.size())
		quit(1)
