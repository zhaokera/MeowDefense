extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_achievement_progress_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const ACHIEVEMENT_PROGRESS_DESIGN_PATH := "res://assets/generated/ui/achievement_progress_guidance_design_reference.png"
const ACHIEVEMENT_PROGRESS_BURST_PATH := "res://assets/generated/ui/achievement_progress_guidance_burst.png"
const ACHIEVEMENT_PROGRESS_BURST_SOURCE_PATH := "res://assets/generated/ui/achievement_progress_guidance_burst_source.png"
const ACHIEVEMENT_PROGRESS_LEVEL_REFERENCE_PATH := "res://assets/generated/ui/achievement_progress_level_guidance_design_reference.png"
const ACHIEVEMENT_PROGRESS_LEVEL_SOURCE_PATH := "res://assets/generated/ui/achievement_progress_level_guidance_badge_source.png"
const ACHIEVEMENT_PROGRESS_LEVEL_BADGE_PATH := "res://assets/generated/ui/achievement_progress_level_guidance_badge.png"

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

	instance.call("_show_achievements_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var claim_button: Button = _assert_button(instance, "AchievementFirstClearClaimButton", "fresh first-clear achievement should expose a claim button")
	if claim_button != null:
		_assert_true(claim_button.disabled, "fresh first-clear achievement claim button should be disabled until progress is complete")

	var row_button: Button = _assert_button(instance, "AchievementFirstClearButton", "fresh first-clear achievement should expose a row guidance hit area")
	if row_button != null:
		row_button.emit_signal("pressed")
		for i: int in range(3):
			await process_frame

	_assert_exists(instance, "AchievementProgressGuidanceOverlay", "clicking an unfinished achievement should open progress guidance")
	_assert_design_texture(
		instance,
		"AchievementProgressGuidanceDesignBackground",
		ACHIEVEMENT_PROGRESS_DESIGN_PATH,
		"achievement progress guidance should render from its Image2 full-screen design"
	)
	_assert_design_texture(
		instance,
		"AchievementProgressGuidanceBurst",
		ACHIEVEMENT_PROGRESS_BURST_PATH,
		"achievement progress guidance should include an Image2 progress burst"
	)
	var title: Label = _assert_label(instance, "AchievementProgressGuidanceTitle", "achievement progress guidance should show the achievement title")
	if title != null:
		_assert_true(title.text.contains("首次守卫"), "achievement progress guidance title should name the selected achievement")
	var requirement: Label = _assert_label(instance, "AchievementProgressGuidanceRequirement", "achievement progress guidance should show the requirement")
	if requirement != null:
		_assert_true(requirement.text.contains("通关任意关卡") and requirement.text.contains("0/1"), "achievement progress guidance should show current progress against target")
	var copy: Label = _assert_label(instance, "AchievementProgressGuidanceCopy", "achievement progress guidance should explain the next action")
	if copy != null:
		_assert_true(copy.text.contains("继续挑战") or copy.text.contains("去关卡"), "achievement progress guidance should point the player back to levels")

	_assert_true(_int_property(instance, "_total_fish") == 0, "unfinished achievement guidance should not grant fish")
	_assert_true(_int_property(instance, "_paw_tokens") == 0, "unfinished achievement guidance should not grant paw tokens")
	_assert_true(not _claimed(instance, "first_clear"), "unfinished achievement guidance should not mark the achievement claimed")

	var close_button: Button = _assert_button(instance, "CloseAchievementProgressGuidanceButton", "achievement progress guidance should be closable")
	if close_button != null:
		close_button.emit_signal("pressed")
		for i: int in range(45):
			await process_frame
		_assert_missing(instance, "AchievementProgressGuidanceOverlay", "closing achievement progress guidance should remove it")

	var stars_row_button: Button = _assert_button(instance, "AchievementStarsButton", "second unfinished achievement should expose a row guidance hit area")
	if stars_row_button != null:
		stars_row_button.emit_signal("pressed")
		for i: int in range(3):
			await process_frame
	var levels_button: Button = _assert_button(instance, "GoLevelsFromAchievementProgressButton", "achievement progress guidance should expose a go-to-levels action")
	if levels_button != null:
		levels_button.emit_signal("pressed")
		for i: int in range(45):
			await process_frame
		_assert_exists(instance, "LevelSelectScreen", "achievement progress guidance action should open level select")
		_assert_missing(instance, "AchievementsOverlay", "achievement progress guidance action should leave the achievements overlay")
		var level_guidance: Control = _assert_control(instance, "AchievementProgressLevelGuidance", "achievement progress route should show a level-select guidance badge")
		if level_guidance != null:
			_assert_true(bool(level_guidance.get_meta("image2_achievement_progress_level_guidance", false)), "achievement progress level guidance should mark Image2 metadata")
			_assert_true(level_guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "achievement progress level guidance should not block level input")
		_assert_texture_node(instance, "AchievementProgressLevelBadge", ACHIEVEMENT_PROGRESS_LEVEL_BADGE_PATH, "achievement progress level guidance should render the Image2 badge")
		var level_label: Label = _assert_label(instance, "AchievementProgressLevelLabel", "achievement progress level guidance should include runtime copy")
		if level_label != null:
			_assert_true(level_label.text.contains("成就") or level_label.text.contains("挑战"), "achievement progress level copy should point to achievement progress")
		var start_level: Button = _assert_button(instance, "StartLevel1Button", "achievement progress level guidance should leave level one tappable")
		if start_level != null:
			_assert_true(not start_level.disabled, "achievement progress level guidance should not disable level one")

	_assert_manifest_entry("achievement_progress_guidance_design_reference", ACHIEVEMENT_PROGRESS_DESIGN_PATH)
	_assert_manifest_entry("achievement_progress_guidance_burst_source", ACHIEVEMENT_PROGRESS_BURST_SOURCE_PATH)
	_assert_manifest_entry("achievement_progress_guidance_burst", ACHIEVEMENT_PROGRESS_BURST_PATH)
	_assert_manifest_entry("achievement_progress_level_guidance_design_reference", ACHIEVEMENT_PROGRESS_LEVEL_REFERENCE_PATH)
	_assert_manifest_entry("achievement_progress_level_guidance_badge_source", ACHIEVEMENT_PROGRESS_LEVEL_SOURCE_PATH)
	_assert_manifest_entry("achievement_progress_level_guidance_badge", ACHIEVEMENT_PROGRESS_LEVEL_BADGE_PATH)

	instance.queue_free()
	_finish()


func _claimed(instance: Node, achievement_id: String) -> bool:
	var raw: Variant = instance.get("_claimed_achievements")
	if raw is Dictionary:
		return bool((raw as Dictionary).get(achievement_id, false))
	return false


func _int_property(instance: Node, property_name: String) -> int:
	var raw: Variant = instance.get(property_name)
	if raw == null:
		return 0
	return int(raw)


func _assert_design_texture(root_node: Node, node_name: String, expected_path: String, message: String) -> void:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return
	if not node is TextureRect:
		_failures.append("%s should be a TextureRect" % node_name)
		return
	var rect: TextureRect = node as TextureRect
	_assert_true(rect.texture != null, "%s should have a texture" % node_name)
	if rect.texture != null:
		_assert_true(rect.texture.resource_path == expected_path, "%s should use %s" % [node_name, expected_path])


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
		print("ACHIEVEMENT PROGRESS GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("ACHIEVEMENT PROGRESS GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear achievement progress guidance test save: %s" % error)
