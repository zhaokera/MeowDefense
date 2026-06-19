extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_result_reward_fly_feedback_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const REWARD_FLY_REFERENCE_PATH := "res://assets/generated/ui/result_reward_fly_feedback_design_reference.png"
const REWARD_FLY_SOURCE_PATH := "res://assets/generated/ui/result_reward_fly_fish_chip_source.png"
const REWARD_FLY_CHIP_PATH := "res://assets/generated/ui/result_reward_fly_fish_chip.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_true(FileAccess.file_exists(REWARD_FLY_REFERENCE_PATH), "result reward fly feedback should keep an Image2 full-screen result reference")
	_assert_true(FileAccess.file_exists(REWARD_FLY_SOURCE_PATH), "result reward fly feedback should keep the Image2 source fish chip")
	_assert_true(FileAccess.file_exists(REWARD_FLY_CHIP_PATH), "result reward fly feedback should use a project-bound transparent Image2 fish chip")
	_assert_manifest_entry("result_reward_fly_feedback_design_reference", REWARD_FLY_REFERENCE_PATH)
	_assert_manifest_entry("result_reward_fly_fish_chip_source", REWARD_FLY_SOURCE_PATH)
	_assert_manifest_entry("result_reward_fly_fish_chip", REWARD_FLY_CHIP_PATH)

	await _assert_victory_result_shows_reward_fly_feedback()
	await _assert_defeat_result_does_not_show_reward_fly_feedback()
	_finish()


func _assert_victory_result_shows_reward_fly_feedback() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.call("_show_result", true, 3, 105)
	await process_frame
	await process_frame

	var fly_layer: Control = _assert_control(instance, "ResultRewardFlyLayer", "winning result should create an Image2 reward fly layer")
	if fly_layer != null:
		_assert_true(fly_layer.z_index > 0, "reward fly layer should render above the result screen art")
	for index: int in range(1, 4):
		var chip: TextureRect = _assert_texture_node(
			instance,
			"ResultRewardFlyFish%d" % index,
			REWARD_FLY_CHIP_PATH,
			"winning result should show reward fly fish chip %d" % index
		)
		if chip != null:
			_assert_true(chip.get_meta("image2_reward_fly_feedback", false), "%s should mark Image2 reward fly feedback metadata" % chip.name)
			_assert_true(chip.position.x >= 420.0 and chip.position.y >= 250.0, "%s should start from the reward area before flying to the counter" % chip.name)
	var counter: Label = _assert_label(instance, "FishCounter", "result should keep the fish counter target")
	if counter != null:
		_assert_true(counter.get_meta("image2_reward_fly_target", false), "fish counter should mark that reward fly feedback targets it")
	_cleanup_instance(instance)


func _assert_defeat_result_does_not_show_reward_fly_feedback() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.call("_show_result", false, 0, 0)
	await process_frame
	await process_frame

	_assert_missing(instance, "ResultRewardFlyLayer", "defeat result should not show reward fly feedback")
	_assert_missing(instance, "ResultRewardFlyFish1", "defeat result should not show reward fly fish chips")
	_cleanup_instance(instance)


func _new_instance() -> Node:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		return null
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame
	return instance


func _cleanup_instance(instance: Node) -> void:
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	_clear_save_file()


func _assert_texture_node(root_node: Node, node_name: String, expected_path: String, message: String) -> TextureRect:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if not node is TextureRect:
		_failures.append("%s should be a TextureRect" % node_name)
		return null
	var texture_rect: TextureRect = node as TextureRect
	_assert_true(texture_rect.texture != null, "%s should have a texture" % node_name)
	if texture_rect.texture != null:
		_assert_true(texture_rect.texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])
	return texture_rect


func _assert_control(root_node: Node, node_name: String, message: String) -> Control:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Control:
		return node as Control
	_failures.append("%s should be a Control" % node_name)
	return null


func _assert_label(root_node: Node, node_name: String, message: String) -> Label:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Label:
		return node as Label
	_failures.append("%s should be a Label" % node_name)
	return null


func _assert_exists(root_node: Node, node_name: String, message: String) -> Node:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
	return node


func _assert_missing(root_node: Node, node_name: String, message: String) -> void:
	if _find_by_name(root_node, node_name) != null:
		_failures.append(message)


func _assert_manifest_entry(id: String, expected_path: String) -> void:
	var manifest_file: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if manifest_file == null:
		_failures.append("asset manifest should be readable")
		return
	var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
	if not (parsed is Dictionary):
		_failures.append("asset manifest should parse as a dictionary")
		return
	var ui_items: Array = (parsed as Dictionary).get("ui", []) as Array
	for item: Variant in ui_items:
		if not (item is Dictionary):
			continue
		var entry: Dictionary = item as Dictionary
		if str(entry.get("id", "")) == id:
			_assert_true(str(entry.get("path", "")) == expected_path, "%s should point to %s" % [id, expected_path])
			return
	_failures.append("asset manifest should include %s" % id)


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


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear result reward fly feedback test save: %s" % error)


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("RESULT REWARD FLY FEEDBACK TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("RESULT REWARD FLY FEEDBACK TESTS FAIL: %d" % _failures.size())
		quit(1)
