extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_daily_task_state_asset_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const STATE_DESIGN_PATH := "res://assets/generated/ui/daily_task_state_design_reference.png"
const CLAIM_BUTTON_PATH := "res://assets/generated/ui/daily_task_claim_button_plate.png"
const CLAIMED_STAMP_PATH := "res://assets/generated/ui/daily_task_claimed_stamp.png"
const PROGRESS_CHIP_PATH := "res://assets/generated/ui/daily_task_progress_chip.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		_finish()
		return

	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame

	instance.set("_best_stars_by_level", {1: 3})
	instance.call("_recalculate_best_stars")
	instance.set("_yarn_traps", 0)
	await _open_daily_tasks(instance)

	_assert_texture(instance, "DailyTaskFirstClearClaimButtonFrame", CLAIM_BUTTON_PATH, "ready first-clear task should use an Image2 claim-button plate")
	_assert_texture(instance, "DailyTaskStarsClaimButtonFrame", CLAIM_BUTTON_PATH, "ready star task should use an Image2 claim-button plate")
	_assert_texture(instance, "DailyTaskYarnProgressChip", PROGRESS_CHIP_PATH, "unfinished yarn task should use an Image2 progress chip")
	_assert_missing(instance, "DailyTaskFirstClearClaimedStamp", "unclaimed ready task should not start with a claimed stamp")
	var claim_button: Button = _assert_button(instance, "ClaimDailyTaskFirstClearButton", "ready task should expose a claim hit area")
	if claim_button != null:
		_assert_true(not claim_button.disabled, "ready task claim hit area should be enabled")
		claim_button.emit_signal("pressed")
		await process_frame
		await process_frame

	var reward_close: Button = _find_by_name(instance, "CloseDailyTaskClaimRewardButton") as Button
	if reward_close != null:
		reward_close.emit_signal("pressed")
		await process_frame
	await _open_daily_tasks(instance)

	_assert_texture(instance, "DailyTaskFirstClearClaimedStamp", CLAIMED_STAMP_PATH, "claimed task should reopen with an Image2 claimed stamp")
	var claimed_button: Button = _assert_button(instance, "ClaimDailyTaskFirstClearButton", "claimed task should still expose the original hit area")
	if claimed_button != null:
		_assert_true(claimed_button.disabled, "claimed task hit area should stay disabled")
	var claimed_label: Label = _assert_label(instance, "DailyTaskFirstClearClaimLabel", "claimed task should keep a dynamic label")
	if claimed_label != null:
		_assert_true(claimed_label.text == "已领取", "claimed task label should stay dynamic over the Image2 stamp")

	_assert_manifest_entry("daily_task_state_design_reference", STATE_DESIGN_PATH)
	_assert_manifest_entry("daily_task_claim_button_plate", CLAIM_BUTTON_PATH)
	_assert_manifest_entry("daily_task_claimed_stamp", CLAIMED_STAMP_PATH)
	_assert_manifest_entry("daily_task_progress_chip", PROGRESS_CHIP_PATH)

	instance.queue_free()
	_finish()


func _open_daily_tasks(instance: Node) -> void:
	var existing: Node = _find_by_name(instance, "DailyTaskOverlay")
	if existing != null:
		existing.queue_free()
		await process_frame
	var task_button: Button = _assert_button(instance, "DailyTaskButton", "main menu should expose daily task entry")
	if task_button != null:
		task_button.emit_signal("pressed")
		await process_frame


func _assert_texture(root_node: Node, node_name: String, expected_path: String, message: String) -> TextureRect:
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


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
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


func _find_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("DAILY TASK STATE ASSET TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("DAILY TASK STATE ASSET TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear daily task state asset test save: %s" % error)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
