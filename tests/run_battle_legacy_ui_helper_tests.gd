extends SceneTree

const BATTLE_SCRIPT_PATH := "res://scripts/battle/battle_scene.gd"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var file := FileAccess.open(BATTLE_SCRIPT_PATH, FileAccess.READ)
	if file == null:
		_failures.append("battle scene script should be readable")
		_finish()
		return
	var source := file.get_as_text()
	_assert_true(not source.contains("func _pause_button("), "battle scene should not retain legacy code-styled pause button helper")
	_assert_true(not source.contains("func _panel_style("), "battle scene should not retain legacy StyleBoxFlat panel helper")
	_assert_true(not source.contains("StyleBoxFlat.new()"), "battle scene should not create code-drawn StyleBoxFlat UI")

	_finish()


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("BATTLE LEGACY UI HELPER TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE LEGACY UI HELPER TESTS FAIL: %d" % _failures.size())
		quit(1)
