extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
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
