extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_result_energy_refill_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/result_energy_refill_guidance_design_reference.png"
const GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/result_energy_refill_guidance_badge_source.png"
const GUIDANCE_BADGE_PATH := "res://assets/generated/ui/result_energy_refill_guidance_badge.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_clear_save_file()
	_assert_file_exists(GUIDANCE_REFERENCE_PATH, "result energy refill guidance should keep an Image2 full-screen design reference")
	_assert_file_exists(GUIDANCE_SOURCE_PATH, "result energy refill guidance should keep an Image2-derived badge source")
	_assert_file_exists(GUIDANCE_BADGE_PATH, "result energy refill guidance should use a transparent runtime badge")
	_assert_manifest_entry("result_energy_refill_guidance_design_reference", GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("result_energy_refill_guidance_badge_source", GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("result_energy_refill_guidance_badge", GUIDANCE_BADGE_PATH)

	await _assert_next_level_with_empty_energy_guides_to_shop_refill()
	await _assert_next_level_with_energy_still_starts_battle()
	_finish()


func _assert_next_level_with_empty_energy_guides_to_shop_refill() -> void:
	var instance: Node = await _new_result_instance(0)
	if instance == null:
		return
	var screen: Control = _assert_control(instance, "ResultScreen", "victory result should open before refill guidance")
	var fish_reward: Label = _assert_label(instance, "ResultFishReward", "zero-fish result should still expose the reward state label")
	if fish_reward != null:
		_assert_true(fish_reward.text != "+0", "zero-fish result reward state should not show a stiff +0 value")
		_assert_true(fish_reward.text.contains("已领取") or fish_reward.text.contains("无"), "zero-fish victory reward state should communicate claimed/no extra reward")
	_assert_missing(instance, "ResultRewardFishChip", "zero-fish result should not show a fish chip celebration")
	_assert_missing(instance, "ResultRewardCountUpLabel", "zero-fish result should not show a +0 count-up label")
	var next_button: Button = _assert_button(instance, "NextLevelButton", "victory result should expose next-level action")
	if next_button != null:
		_assert_true(not next_button.disabled, "next-level action should stay tappable before empty-energy guidance")
		next_button.emit_signal("pressed")
		await process_frame
		await process_frame

	_assert_exists(instance, "ResultScreen", "empty-energy next route should keep the result screen visible")
	_assert_missing(instance, "BattleScene", "empty-energy next route should not start battle")
	_assert_missing(instance, "EnergyEmptyOverlay", "empty-energy result route should not hard-cut to the generic energy overlay")
	var guidance: Control = _assert_control(instance, "ResultEnergyRefillGuidance", "empty-energy next route should show result-specific refill guidance")
	if guidance != null:
		_assert_true(bool(guidance.get_meta("image2_result_energy_refill_guidance", false)), "result refill guidance should mark Image2 metadata")
		_assert_true(guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "result refill guidance group should not block its route button")
	var badge: TextureRect = _assert_texture_node(instance, "ResultEnergyRefillBadge", GUIDANCE_BADGE_PATH, "result refill guidance should render the Image2 badge")
	if badge != null:
		_assert_true(badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "result refill badge should not block route button")
	var label: Label = _assert_label(instance, "ResultEnergyRefillLabel", "result refill guidance should include runtime copy")
	if label != null:
		_assert_true(label.text.contains("体力") or label.text.contains("补"), "result refill guidance should point to refilling energy")
	var route_button: Button = _assert_button(instance, "ResultEnergyRefillButton", "result refill guidance should expose a shop route")
	if screen != null and route_button != null:
		route_button.emit_signal("pressed")
		_assert_true(bool(screen.get_meta("image2_result_exit_animation", false)), "result refill route should animate the Image2 result screen out")
		_assert_true(route_button.disabled, "result refill route should disable while routing")
		await _wait_until_missing(instance, "ResultScreen")

	_assert_exists(instance, "ShopOverlay", "result refill route should open the shop")
	var target: Control = _assert_control(instance, "ShopEnergyRefillButtonFrame", "shop should show refill target after result refill guidance")
	if target != null:
		_assert_true(bool(target.get_meta("image2_result_energy_refill_target", false)), "shop refill target should be marked after result refill guidance")
	var shop_button: Button = _assert_button(instance, "BuyShopEnergyRefillButton", "shop should expose energy refill purchase")
	if shop_button != null:
		_assert_true(not shop_button.disabled, "energy refill purchase should be enabled with enough fish")
	_assert_true(int(instance.get("_energy")) == 0, "result refill guidance should not grant energy before purchase")
	_cleanup_instance(instance)


func _assert_next_level_with_energy_still_starts_battle() -> void:
	var instance: Node = await _new_result_instance(1)
	if instance == null:
		return
	var next_button: Button = _assert_button(instance, "NextLevelButton", "victory result should expose next-level action with energy")
	if next_button != null:
		next_button.emit_signal("pressed")
		await _wait_until_exists(instance, "BattleScene")
	_assert_missing(instance, "ResultEnergyRefillGuidance", "normal next-level starts should not show refill guidance")
	_assert_exists(instance, "BattleScene", "next-level action with energy should still start battle")
	_assert_true(int(instance.get("_current_level_id")) == 2, "next-level action should start level two when energy is available")
	_cleanup_instance(instance)


func _new_result_instance(current_energy: int) -> Node:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_failures.append("main scene should load")
		return null
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	instance.set("_reward_date_override", "2026-06-20")
	instance.set("_energy_refilled_on", "2026-06-20")
	instance.set("_max_energy", 15)
	instance.set("_energy", current_energy)
	instance.set("_total_fish", 25)
	instance.set("_current_level_id", 1)
	instance.set("_unlocked_level", 2)
	instance.set("_claimed_achievements", {"first_clear": true})
	root.add_child(instance)
	await process_frame
	instance.set("_energy_refilled_on", "2026-06-20")
	instance.set("_energy", current_energy)
	instance.call("_show_result", true, 3, 0)
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
		print("RESULT ENERGY REFILL GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("RESULT ENERGY REFILL GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear result energy refill guidance test save: %s" % error)
