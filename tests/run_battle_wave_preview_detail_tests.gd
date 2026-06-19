extends SceneTree

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const PREVIEW_REFERENCE_PATH := "res://assets/generated/ui/battle_wave_preview_detail_design_reference.png"
const PREVIEW_PANEL_SOURCE_PATH := "res://assets/generated/ui/battle_wave_preview_detail_panel_source.png"
const PREVIEW_PANEL_PATH := "res://assets/generated/ui/battle_wave_preview_detail_panel.png"
const PREVIEW_BADGE_PATH := "res://assets/generated/ui/battle_wave_preview_info_badge.png"
const RAT_TANK_ICON_PATH := "res://assets/generated/enemies/rat_tank.png"
const HAMSTER_RUNNER_ICON_PATH := "res://assets/generated/enemies/hamster_runner.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_true(FileAccess.file_exists(PREVIEW_REFERENCE_PATH), "wave preview detail should keep an Image2 full-screen battle reference")
	_assert_true(FileAccess.file_exists(PREVIEW_PANEL_SOURCE_PATH), "wave preview detail should keep the Image2-derived panel source")
	_assert_true(FileAccess.file_exists(PREVIEW_PANEL_PATH), "wave preview detail should use a project-bound transparent Image2 panel")
	_assert_true(FileAccess.file_exists(PREVIEW_BADGE_PATH), "wave preview detail should expose a project-bound Image2 info badge")
	_assert_true(FileAccess.file_exists(RAT_TANK_ICON_PATH), "wave preview detail should keep a project-bound tank rat preview icon")
	_assert_true(FileAccess.file_exists(HAMSTER_RUNNER_ICON_PATH), "wave preview detail should keep a project-bound hamster runner preview icon")
	_assert_manifest_entry("battle_wave_preview_detail_design_reference", PREVIEW_REFERENCE_PATH)
	_assert_manifest_entry("battle_wave_preview_detail_panel_source", PREVIEW_PANEL_SOURCE_PATH)
	_assert_manifest_entry("battle_wave_preview_detail_panel", PREVIEW_PANEL_PATH)
	_assert_manifest_entry("battle_wave_preview_info_badge", PREVIEW_BADGE_PATH)
	_assert_manifest_entry("rat_tank_preview_icon", RAT_TANK_ICON_PATH)
	_assert_manifest_entry("hamster_runner_preview_icon", HAMSTER_RUNNER_ICON_PATH)

	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	await process_frame
	await physics_frame

	_assert_texture_node(
		battle,
		"WavePreviewInfoBadge",
		PREVIEW_BADGE_PATH,
		"wave preview chip should expose a visible Image2 info badge"
	)
	var info_button: Button = _assert_button(battle, "WavePreviewInfoButton", "wave preview should expose a separate info hotspot")
	if info_button != null:
		_assert_true(info_button.text == "", "wave preview info hotspot should not draw visible button text")
		info_button.emit_signal("pressed")
	await process_frame
	await process_frame

	var overlay: Control = _assert_control(battle, "BattleWavePreviewDetailOverlay", "tapping wave preview info should open the wave detail overlay")
	if overlay != null:
		_assert_true(overlay.get_meta("image2_wave_preview_detail", false), "wave preview detail should mark Image2 metadata")
	_assert_texture_node(
		battle,
		"BattleWavePreviewDetailPanel",
		PREVIEW_PANEL_PATH,
		"wave preview detail should render from a transparent Image2 panel"
	)
	_assert_texture_node(
		battle,
		"WavePreviewEnemyIcon",
		"res://assets/generated/enemies/mouse_basic.png",
		"wave preview detail should show the next enemy Image2 icon"
	)
	var title: Label = _assert_label(battle, "WavePreviewDetailTitle", "wave preview detail should include a dynamic title")
	if title != null:
		_assert_true(title.text.contains("第 1/3 波"), "wave preview detail title should identify the next wave")
	var enemy: Label = _assert_label(battle, "WavePreviewEnemyName", "wave preview detail should include enemy name")
	if enemy != null:
		_assert_true(enemy.text.contains("偷鱼干小鼠"), "wave preview detail should show the next enemy name")
	var count: Label = _assert_label(battle, "WavePreviewEnemyCount", "wave preview detail should include enemy count")
	if count != null:
		_assert_true(count.text.contains("x8"), "wave preview detail should show the remaining enemy count")
	var reward: Label = _assert_label(battle, "WavePreviewRewardLabel", "wave preview detail should include reward guidance")
	if reward != null:
		_assert_true(reward.text.contains("小鱼干"), "wave preview detail should mention fish reward")
	var timer: Label = _assert_label(battle, "WavePreviewTimerLabel", "wave preview detail should include countdown")
	if timer != null:
		_assert_true(timer.text.contains("0."), "wave preview detail should show time until wave")
	var close_button: Button = _assert_button(battle, "CloseWavePreviewDetailButton", "wave preview detail should be closable")
	if close_button != null:
		close_button.emit_signal("pressed")
	await _wait_until_missing(battle, "BattleWavePreviewDetailOverlay")
	_assert_missing(battle, "BattleWavePreviewDetailOverlay", "closing wave preview detail should remove the overlay")

	if info_button != null:
		info_button.emit_signal("pressed")
	await process_frame
	await process_frame
	var start_button: Button = _assert_button(battle, "StartWaveFromPreviewButton", "wave preview detail should offer early wave start")
	var enemies_before: int = int(battle.enemies.size())
	if start_button != null:
		start_button.emit_signal("pressed")
	await process_frame
	await physics_frame
	await process_frame
	_assert_true(int(battle.enemies.size()) > enemies_before, "starting from wave detail should spawn the next enemy immediately")
	await _wait_until_missing(battle, "BattleWavePreviewDetailOverlay")
	_assert_missing(battle, "BattleWavePreviewDetailOverlay", "starting wave from detail should close the overlay")

	battle.queue_free()
	await _assert_later_wave_uses_single_enemy_icon()
	_finish()


func _assert_later_wave_uses_single_enemy_icon() -> void:
	var battle: Node2D = BattleSceneScript.new()
	root.add_child(battle)
	battle.start_level("res://data/levels/level_002.json")
	await process_frame
	await physics_frame
	var wave_states: Array = battle.get("_wave_states") as Array
	if wave_states.size() >= 3:
		(wave_states[0] as Dictionary)["remaining"] = 0
		(wave_states[1] as Dictionary)["remaining"] = 0
	var info_button: Button = _assert_button(battle, "WavePreviewInfoButton", "wave preview should expose info hotspot for later waves")
	if info_button != null:
		info_button.emit_signal("pressed")
	await process_frame
	await process_frame
	_assert_texture_node(
		battle,
		"WavePreviewEnemyIcon",
		RAT_TANK_ICON_PATH,
		"wave preview detail should use the tank rat single-frame icon"
	)
	var enemy: Label = _assert_label(battle, "WavePreviewEnemyName", "tank wave preview should include enemy name")
	if enemy != null:
		_assert_true(enemy.text.contains("罐头胖鼠"), "tank wave preview should name the tank rat")
	battle.queue_free()


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
	var manifest: Dictionary = parsed as Dictionary
	for key: Variant in manifest.keys():
		if not (manifest[key] is Array):
			continue
		var items: Array = manifest[key] as Array
		for item: Variant in items:
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


func _wait_until_missing(root_node: Node, node_name: String) -> void:
	for i: int in range(90):
		if _find_by_name(root_node, node_name) == null:
			return
		await process_frame


func _finish() -> void:
	if _failures.is_empty():
		print("BATTLE WAVE PREVIEW DETAIL TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("BATTLE WAVE PREVIEW DETAIL TESTS FAIL: %d" % _failures.size())
		quit(1)
