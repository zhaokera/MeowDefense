extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_main_scene_contract()
	_assert_project_input_contract()

	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
	else:
		var instance: Node = scene.instantiate()
		if instance == null:
			_failures.append("main scene should instantiate")
		else:
			root.add_child(instance)
			await process_frame
			instance.queue_free()

	if _failures.is_empty():
		print("SCENE SMOKE PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("SCENE SMOKE FAIL: %d" % _failures.size())
		quit(1)


func _assert_main_scene_contract() -> void:
	var file: FileAccess = FileAccess.open("res://scenes/main.tscn", FileAccess.READ)
	if file == null:
		_failures.append("main scene file should be readable")
		return
	var source: String = file.get_as_text()
	_assert_true(source.contains("[node name=\"Main\" type=\"Control\"]"), "main scene should keep the MeowDefense Control root")
	_assert_true(source.contains("res://scripts/app/main.gd"), "main scene should keep the MeowDefense app script")
	_assert_true(not source.contains("res://scenes/player.tscn"), "main scene should not instance unrelated platformer player scenes")
	_assert_true(not source.contains("type=\"StaticBody2D\""), "main scene should not contain prototype platform bodies")
	_assert_true(not source.contains("type=\"Camera2D\""), "main scene should not contain prototype camera nodes")
	_assert_true(not source.contains("type=\"ColorRect\""), "main scene should not contain code-drawn prototype platform visuals")


func _assert_project_input_contract() -> void:
	var file: FileAccess = FileAccess.open("res://project.godot", FileAccess.READ)
	if file == null:
		_failures.append("project.godot should be readable")
		return
	var source: String = file.get_as_text()
	for action_name: String in ["move_left", "move_right", "jump", "attack", "dodge"]:
		_assert_true(not source.contains("%s={" % action_name), "project input map should not contain unrelated platformer action %s" % action_name)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
