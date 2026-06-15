extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_reward_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const DAILY_REWARD_CLAIM_SUCCESS_DESIGN_PATH := "res://assets/generated/ui/daily_reward_claim_success_design_reference.png"
const DAILY_REWARD_CLAIM_SUCCESS_BURST_PATH := "res://assets/generated/ui/daily_reward_claim_success_burst.png"
const DAILY_REWARD_CLAIM_SUCCESS_BURST_SOURCE_PATH := "res://assets/generated/ui/daily_reward_claim_success_burst_source.png"

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
	var reward_button: Button = _assert_button(instance, "DailyRewardButton", "main menu should expose daily reward")
	if reward_button != null:
		reward_button.emit_signal("pressed")
		await process_frame

	_assert_exists(instance, "RewardOverlay", "reward should open as an overlay")
	_assert_texture_node(
		instance,
		"RewardDesignPanel",
		"res://assets/generated/ui/reward_overlay_panel.png",
		"reward should use an Image2 panel asset"
	)
	_assert_texture_node(
		instance,
		"RewardChestFrame",
		"res://assets/generated/ui/reward_chest.png",
		"reward should use an Image2 chest asset"
	)
	_assert_texture_node(
		instance,
		"RewardClaimFrame",
		"res://assets/generated/ui/reward_claim_button.png",
		"reward claim should use an Image2 button frame"
	)
	_assert_missing(instance, "RewardPanel", "reward should not render the old code-drawn panel")

	var claim_button: Button = _assert_button(instance, "ClaimRewardButton", "reward should expose a claim button")
	if claim_button != null:
		claim_button.emit_signal("pressed")
		await process_frame
		await process_frame
		_assert_true(int(instance.get("_total_fish")) == before_fish + 20, "claiming reward should add 20 fish")
		_assert_missing(instance, "RewardOverlay", "reward overlay should close after claiming")
		_assert_exists(instance, "DailyRewardClaimSuccessOverlay", "claiming daily reward should open a success feedback overlay")
		_assert_texture_node(
			instance,
			"DailyRewardClaimSuccessDesignBackground",
			DAILY_REWARD_CLAIM_SUCCESS_DESIGN_PATH,
			"daily reward claim success should render from its Image2 full-screen design"
		)
		_assert_texture_node(
			instance,
			"DailyRewardClaimSuccessBurst",
			DAILY_REWARD_CLAIM_SUCCESS_BURST_PATH,
			"daily reward claim success should include the Image2 reward burst asset"
		)
		var success_amount: Label = _assert_label(instance, "DailyRewardClaimSuccessAmount", "daily reward success should show the reward amount")
		if success_amount != null:
			_assert_true(success_amount.text.contains("小鱼干 +20"), "daily reward success should show fish reward")
		var success_streak: Label = _assert_label(instance, "DailyRewardClaimSuccessStreak", "daily reward success should show the current streak")
		if success_streak != null:
			_assert_true(success_streak.text.contains("连续 1 天"), "daily reward success should show the first-day streak")
		var success_close: Button = _assert_button(instance, "CloseDailyRewardClaimSuccessButton", "daily reward success should be closable")
		if success_close != null:
			success_close.emit_signal("pressed")
			await process_frame
			_assert_missing(instance, "DailyRewardClaimSuccessOverlay", "closing daily reward success should remove it")

	_assert_manifest_entry("daily_reward_claim_success_design_reference", DAILY_REWARD_CLAIM_SUCCESS_DESIGN_PATH)
	_assert_manifest_entry("daily_reward_claim_success_burst_source", DAILY_REWARD_CLAIM_SUCCESS_BURST_SOURCE_PATH)
	_assert_manifest_entry("daily_reward_claim_success_burst", DAILY_REWARD_CLAIM_SUCCESS_BURST_PATH)

	instance.queue_free()
	_finish()


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
		print("REWARD OVERLAY TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("REWARD OVERLAY TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear reward test save: %s" % error)
