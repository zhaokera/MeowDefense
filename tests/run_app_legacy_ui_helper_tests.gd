extends SceneTree

const APP_SCRIPT_PATH := "res://scripts/app/main.gd"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var file := FileAccess.open(APP_SCRIPT_PATH, FileAccess.READ)
	if file == null:
		_failures.append("app script should be readable")
		_finish()
		return
	var source := file.get_as_text()
	_assert_true(not source.contains("func _panel("), "main app should not retain legacy visible Panel helper")
	_assert_true(not source.contains("func _button("), "main app should not retain legacy visible Button helper")
	_assert_true(not source.contains("func _toggle("), "main app should not retain legacy visible CheckButton helper")
	_assert_true(not source.contains("func _style("), "main app should not retain legacy StyleBoxFlat helper for visible UI")
	_assert_true(not source.contains("Panel.new()"), "main app should not create visible code-drawn Panel nodes")

	_finish()


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("APP LEGACY UI HELPER TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("APP LEGACY UI HELPER TESTS FAIL: %d" % _failures.size())
		quit(1)
