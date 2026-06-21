extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_result_achievement_claim_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/result_achievement_claim_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/result_achievement_claim_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/result_achievement_claim_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "result achievement guidance should keep an Image2 full-screen design reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "result achievement guidance should keep an Image2-derived badge source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "result achievement guidance should use a transparent runtime badge")
	_assert_manifest_entry("result_achievement_claim_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("result_achievement_claim_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("result_achievement_claim_guidance_badge", GUIDANCE_BADGE_PATH)

	await _assert_first_clear_result_routes_to_achievements()
	await _assert_final_clear_prioritizes_campaign_achievement()
	await _assert_defeat_result_has_no_achievement_guidance()
	await _assert_claimed_achievement_result_has_no_guidance()
	_finish()


func _assert_first_clear_result_routes_to_achievements() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_current_level_id", 1)
	instance.set("_unlocked_level", 1)
	instance.call("_show_result", true, 3, 35)
	await process_frame
	await process_frame

	var screen: Control = _assert_control(instance, "ResultScreen", "victory result should open before achievement guidance")
	var guidance: Control = _assert_control(instance, "ResultAchievementClaimGuidance", "first clear result should show completed-achievement guidance")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_result_achievement_claim_guidance", false)), "result achievement guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "result achievement guidance group should not block its route button")
	var badge: TextureRect = _assert_texture_node(instance, "ResultAchievementClaimGuidanceBadge", GUIDANCE_BADGE_PATH, "result achievement guidance should render the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "result achievement guidance badge should not block route button")
	var label: Label = _assert_label(instance, "ResultAchievementClaimGuidanceLabel", "result achievement guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("成就") or label.text.contains("领取"), "result achievement guidance should point to claimable achievements")
	var route_button: Button = _assert_button(instance, "ResultAchievementClaimGuidanceButton", "result achievement guidance should expose an achievements route")
	if screen != null and route_button != null:
		route_button.emit_signal("pressed")
		_assert_true(bool(screen.get_meta("image2_result_exit_animation", false)), "achievement route should animate the Image2 result screen out")
		_assert_true(route_button.disabled, "achievement route should disable while routing")
		_assert_missing(instance, "AchievementsOverlay", "achievement route should not hard-cut before result exit")
		await _wait_until_missing(instance, "ResultScreen")
		await _wait_until_exists(instance, "AchievementsOverlay")

	_assert_exists(instance, "AchievementsOverlay", "achievement route should open achievements overlay after result exit")
	var claim_button: Button = _assert_button(instance, "AchievementFirstClearClaimButton", "routed achievements overlay should expose first-clear claim")
	if claim_button != null:
		_assert_true(not claim_button.disabled, "first-clear achievement should be claimable after routing from result")
	_assert_true(int(instance.get("_total_fish")) == 35, "routing to achievements should preserve victory fish reward")
	_cleanup_instance(instance)


func _assert_final_clear_prioritizes_campaign_achievement() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_current_level_id", 5)
	instance.set("_unlocked_level", 5)
	instance.set("_best_stars_by_level", {1: 3, 2: 3, 3: 3, 4: 3})
	instance.call("_recalculate_best_stars")
	instance.call("_show_result", true, 3, 120)
	await process_frame
	await process_frame

	var guidance: Control = _assert_control(instance, "ResultAchievementClaimGuidance", "final campaign clear should show completed-achievement guidance")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_result_achievement_claim_guidance", false)), "final campaign guidance should reuse the Image2 result achievement badge")
	var sub_label: Label = _assert_label(instance, "ResultAchievementClaimGuidanceSubLabel", "final campaign guidance should name the claimable achievement")
	if sub_label != null:
		_assert_true(sub_label.text.contains("连续推进"), "final campaign clear should prioritize the campaign-clear achievement")
	var route_button: Button = _assert_button(instance, "ResultAchievementClaimGuidanceButton", "final campaign guidance should expose an achievements route")
	var screen: Control = _assert_control(instance, "ResultScreen", "final campaign result screen should stay visible before routing")
	if screen != null and route_button != null:
		route_button.emit_signal("pressed")
		_assert_true(bool(screen.get_meta("image2_result_exit_animation", false)), "final campaign achievement route should animate the Image2 result screen out")
		await _wait_until_exists(instance, "AchievementsOverlay")
	var campaign_claim: Button = _assert_button(instance, "AchievementCampaignClaimButton", "routed achievements overlay should expose campaign-clear claim")
	if campaign_claim != null:
		_assert_true(not campaign_claim.disabled, "campaign-clear achievement should be claimable after final clear")
	_cleanup_instance(instance)


func _assert_defeat_result_has_no_achievement_guidance() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.call("_show_result", false, 0, 0)
	await process_frame
	_assert_missing(instance, "ResultAchievementClaimGuidance", "defeat result should not show claimable achievement guidance")
	_cleanup_instance(instance)


func _assert_claimed_achievement_result_has_no_guidance() -> void:
	var instance: Node = await _new_instance()
	if instance == null:
		return
	instance.set("_claimed_achievements", {"first_clear": true})
	instance.set("_current_level_id", 1)
	instance.call("_show_result", true, 3, 35)
	await process_frame
	_assert_missing(instance, "ResultAchievementClaimGuidance", "claimed achievements should not show result claim guidance")
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
	await process_frame
	_clear_save_file()


func _assert_manifest_entry(entry_id: String, expected_path: String) -> void:
	if not FileAccess.file_exists(MANIFEST_PATH):
		_failures.append("assets manifest should exist")
		return
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		_failures.append("assets manifest should be readable")
		return
	var data: Variant = JSON.parse_string(file.get_as_text())
	if not data is Dictionary:
		_failures.append("assets manifest should be a JSON object")
		return
	var entries: Array = (data as Dictionary).get("ui", []) as Array
	for entry: Variant in entries:
		if entry is Dictionary and str(entry.get("id", "")) == entry_id:
			_assert_true(str(entry.get("path", "")) == expected_path, "%s should point at %s" % [entry_id, expected_path])
			return
	_failures.append("assets manifest should include %s" % entry_id)


func _assert_file_exists(path: String, message: String) -> void:
	if not FileAccess.file_exists(path):
		_failures.append(message)


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


func _assert_control(root_node: Node, node_name: String, message: String) -> Control:
	var node: Node = _assert_exists(root_node, node_name, message)
	if node == null:
		return null
	if node is Control:
		return node as Control
	_failures.append("%s should be a Control" % node_name)
	return null


func _assert_exists(root_node: Node, node_name: String, message: String) -> Node:
	var node: Node = _find_by_name(root_node, node_name)
	if node == null:
		_failures.append(message)
	return node


func _assert_missing(root_node: Node, node_name: String, message: String) -> void:
	if _find_by_name(root_node, node_name) != null:
		_failures.append(message)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _find_by_name(node: Node, node_name: String) -> Node:
	if node == null:
		return null
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_by_name(child, node_name)
		if found != null:
			return found
	return null


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) != null:
			return
		await process_frame


func _wait_until_missing(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if _find_by_name(root_node, node_name) == null:
			return
		await process_frame


func _finish() -> void:
	_clear_save_file()
	if _failures.is_empty():
		print("RESULT ACHIEVEMENT CLAIM GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("RESULT ACHIEVEMENT CLAIM GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear result achievement guidance test save: %s" % error)
