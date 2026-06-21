extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_daily_task_progress_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const DAILY_TASK_PROGRESS_DESIGN_PATH := "res://assets/generated/ui/daily_task_progress_guidance_design_reference.png"
const DAILY_TASK_PROGRESS_BURST_PATH := "res://assets/generated/ui/daily_task_progress_guidance_burst.png"
const DAILY_TASK_PROGRESS_BURST_SOURCE_PATH := "res://assets/generated/ui/daily_task_progress_guidance_burst_source.png"
const DAILY_TASK_PROGRESS_LEVEL_REFERENCE_PATH := "res://assets/generated/ui/daily_task_progress_level_guidance_design_reference.png"
const DAILY_TASK_PROGRESS_LEVEL_SOURCE_PATH := "res://assets/generated/ui/daily_task_progress_level_guidance_badge_source.png"
const DAILY_TASK_PROGRESS_LEVEL_BADGE_PATH := "res://assets/generated/ui/daily_task_progress_level_guidance_badge.png"

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

	var before_fish: int = int(instance.get("_total_fish"))
	var task_button: Button = _assert_button(instance, "DailyTaskButton", "main menu should expose daily task entry")
	if task_button != null:
		task_button.emit_signal("pressed")
		await process_frame

	_assert_exists(instance, "DailyTaskOverlay", "daily task entry should open daily task overlay")
	var progress: Label = _assert_label(instance, "DailyTaskFirstClearProgress", "fresh daily task should show first-clear progress")
	if progress != null:
		_assert_true(progress.text.contains("0/1"), "fresh first-clear daily task should be unfinished")
	var claim: Button = _assert_button(instance, "ClaimDailyTaskFirstClearButton", "unfinished daily task should still expose its claim state")
	if claim != null:
		_assert_true(claim.disabled, "unfinished daily task claim should stay disabled")

	var progress_button: Button = _assert_button(instance, "DailyTaskFirstClearProgressButton", "unfinished daily task should expose a progress guidance hit area")
	if progress_button != null:
		progress_button.emit_signal("pressed")
		for _frame: int in range(3):
			await process_frame

	_assert_exists(instance, "DailyTaskProgressGuidanceOverlay", "clicking unfinished daily task should open progress guidance")
	_assert_texture_node(
		instance,
		"DailyTaskProgressGuidanceDesignBackground",
		DAILY_TASK_PROGRESS_DESIGN_PATH,
		"daily task progress guidance should render from its Image2 full-screen design"
	)
	_assert_texture_node(
		instance,
		"DailyTaskProgressGuidanceBurst",
		DAILY_TASK_PROGRESS_BURST_PATH,
		"daily task progress guidance should include an Image2 progress burst"
	)
	var title: Label = _assert_label(instance, "DailyTaskProgressGuidanceTitle", "daily task progress guidance should show the task title")
	if title != null:
		_assert_true(title.text.contains("今日守卫"), "daily task progress guidance should name the selected task")
	var requirement: Label = _assert_label(instance, "DailyTaskProgressGuidanceRequirement", "daily task progress guidance should show the requirement")
	if requirement != null:
		_assert_true(requirement.text.contains("通关任意关卡") and requirement.text.contains("0/1"), "daily task progress guidance should show current progress against target")
	var copy: Label = _assert_label(instance, "DailyTaskProgressGuidanceCopy", "daily task progress guidance should explain the next action")
	if copy != null:
		_assert_true(copy.text.contains("关卡") or copy.text.contains("挑战"), "daily task progress guidance should point the player toward gameplay")

	_assert_true(int(instance.get("_total_fish")) == before_fish, "unfinished daily task guidance should not grant fish")
	_assert_true(not _daily_task_claimed(instance, "first_clear"), "unfinished daily task guidance should not mark the task claimed")

	var close_button: Button = _assert_button(instance, "CloseDailyTaskProgressGuidanceButton", "daily task progress guidance should be closable")
	if close_button != null:
		close_button.emit_signal("pressed")
		for _frame: int in range(45):
			await process_frame
		_assert_missing(instance, "DailyTaskProgressGuidanceOverlay", "closing daily task progress guidance should remove it")

	if progress_button != null:
		progress_button.emit_signal("pressed")
		await _wait_until_exists(instance, "GoLevelsFromDailyTaskProgressButton")
	var levels_button: Button = _assert_button(instance, "GoLevelsFromDailyTaskProgressButton", "daily task progress guidance should expose a go-to-levels action")
	if levels_button != null:
		levels_button.emit_signal("pressed")
		for _frame: int in range(45):
			await process_frame
		_assert_exists(instance, "LevelSelectScreen", "daily task progress action should open level select")
		_assert_missing(instance, "DailyTaskOverlay", "daily task progress action should leave the daily task overlay")
		var level_guidance: Control = _assert_control(instance, "DailyTaskProgressLevelGuidance", "daily task progress route should show a level-select guidance badge")
		if level_guidance != null:
			_assert_true(bool(level_guidance.get_meta("image2_daily_task_progress_level_guidance", false)), "daily task progress level guidance should mark Image2 metadata")
			_assert_true(level_guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "daily task progress level guidance should not block level input")
		_assert_texture_node(instance, "DailyTaskProgressLevelBadge", DAILY_TASK_PROGRESS_LEVEL_BADGE_PATH, "daily task progress level guidance should render the Image2 badge")
		var level_label: Label = _assert_label(instance, "DailyTaskProgressLevelLabel", "daily task progress level guidance should include runtime copy")
		if level_label != null:
			_assert_true(level_label.text.contains("任务") or level_label.text.contains("通关"), "daily task progress level copy should point back to the unfinished task")
		var start_level: Button = _assert_button(instance, "StartLevel1Button", "daily task progress guidance should leave level one tappable")
		if start_level != null:
			_assert_true(not start_level.disabled, "daily task progress level guidance should not disable level one")

	_assert_manifest_entry("daily_task_progress_guidance_design_reference", DAILY_TASK_PROGRESS_DESIGN_PATH)
	_assert_manifest_entry("daily_task_progress_guidance_burst_source", DAILY_TASK_PROGRESS_BURST_SOURCE_PATH)
	_assert_manifest_entry("daily_task_progress_guidance_burst", DAILY_TASK_PROGRESS_BURST_PATH)
	_assert_manifest_entry("daily_task_progress_level_guidance_design_reference", DAILY_TASK_PROGRESS_LEVEL_REFERENCE_PATH)
	_assert_manifest_entry("daily_task_progress_level_guidance_badge_source", DAILY_TASK_PROGRESS_LEVEL_SOURCE_PATH)
	_assert_manifest_entry("daily_task_progress_level_guidance_badge", DAILY_TASK_PROGRESS_LEVEL_BADGE_PATH)

	instance.queue_free()
	_finish()


func _daily_task_claimed(instance: Node, task_id: String) -> bool:
	var raw: Variant = instance.get("_claimed_daily_tasks")
	if raw is Dictionary:
		return bool((raw as Dictionary).get(task_id, false))
	return false


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 180) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) != null:
			return
		await process_frame


func _assert_button(root_node: Node, node_name: String, message: String) -> Button:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Button:
		return node as Button
	_failures.append("%s should be a Button" % node_name)
	return null


func _assert_control(root_node: Node, node_name: String, message: String) -> Control:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Control:
		return node as Control
	_failures.append("%s should be a Control" % node_name)
	return null


func _assert_texture_node(root_node: Node, node_name: String, expected_path: String, message: String) -> TextureRect:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if not node is TextureRect:
		_failures.append("%s should be a TextureRect" % node_name)
		return null
	var texture_node: TextureRect = node as TextureRect
	_assert_true(texture_node.texture != null, "%s should have a texture" % node_name)
	if texture_node.texture != null:
		_assert_true(texture_node.texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])
	return texture_node


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


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("DAILY TASK PROGRESS GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("DAILY TASK PROGRESS GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear daily task progress guidance test save: %s" % error)
