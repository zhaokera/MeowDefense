extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_daily_task_progress_shop_guidance_test_save.json"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const SHOP_GUIDANCE_REFERENCE_PATH := "res://assets/generated/ui/daily_task_progress_shop_guidance_design_reference.png"
const SHOP_GUIDANCE_SOURCE_PATH := "res://assets/generated/ui/daily_task_progress_shop_guidance_badge_source.png"
const SHOP_GUIDANCE_BADGE_PATH := "res://assets/generated/ui/daily_task_progress_shop_guidance_badge.png"

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
	instance.set("_total_fish", 25)

	var task_button: Button = _assert_button(instance, "DailyTaskButton", "main menu should expose daily task entry")
	if task_button != null:
		task_button.emit_signal("pressed")
		await process_frame

	var yarn_progress: Label = _assert_label(instance, "DailyTaskYarnProgress", "daily task overlay should show yarn readiness progress")
	if yarn_progress != null:
		_assert_true(yarn_progress.text.contains("0/1"), "fresh yarn daily task should be unfinished")
	var yarn_progress_button: Button = _assert_button(instance, "DailyTaskYarnProgressButton", "unfinished yarn task should expose a progress guidance hit area")
	if yarn_progress_button != null:
		yarn_progress_button.emit_signal("pressed")
		for _frame: int in range(3):
			await process_frame

	_assert_exists(instance, "DailyTaskProgressGuidanceOverlay", "clicking unfinished yarn task should open progress guidance")
	var title: Label = _assert_label(instance, "DailyTaskProgressGuidanceTitle", "yarn progress guidance should show task title")
	if title != null:
		_assert_true(title.text.contains("准备毛线"), "yarn progress guidance should name the yarn task")
	var copy: Label = _assert_label(instance, "DailyTaskProgressGuidanceCopy", "yarn progress guidance should explain the next action")
	if copy != null:
		_assert_true(copy.text.contains("商店") or copy.text.contains("毛线"), "yarn progress guidance should point toward shop preparation")
	_assert_missing(instance, "GoLevelsFromDailyTaskProgressButton", "yarn readiness task should not route to levels")
	var shop_action: Button = _assert_button(instance, "GoShopFromDailyTaskProgressButton", "yarn progress guidance should expose a go-to-shop action")
	if shop_action != null:
		shop_action.emit_signal("pressed")
		for _frame: int in range(45):
			await process_frame

	_assert_exists(instance, "ShopOverlay", "yarn progress shop action should open shop")
	_assert_missing(instance, "DailyTaskOverlay", "yarn progress shop action should leave daily tasks")
	var shop_guidance: Control = _assert_control(instance, "DailyTaskProgressShopGuidance", "daily task yarn route should show a shop guidance badge")
	if shop_guidance != null:
		_assert_true(bool(shop_guidance.get_meta("image2_daily_task_progress_shop_guidance", false)), "daily task shop guidance should mark Image2 metadata")
		_assert_true(shop_guidance.mouse_filter == Control.MOUSE_FILTER_IGNORE, "daily task shop guidance should not block product input")
	_assert_texture_node(instance, "DailyTaskProgressShopBadge", SHOP_GUIDANCE_BADGE_PATH, "daily task shop guidance should render the Image2 badge")
	var shop_label: Label = _assert_label(instance, "DailyTaskProgressShopLabel", "daily task shop guidance should include runtime copy")
	if shop_label != null:
		_assert_true(shop_label.text.contains("毛线"), "daily task shop guidance should point to yarn")
	var yarn_buy: Button = _assert_button(instance, "BuyShopYarnTrapKitButton", "shop should expose yarn purchase after daily task route")
	if yarn_buy != null:
		_assert_true(not yarn_buy.disabled, "daily task yarn route should leave affordable yarn purchase tappable")
		_assert_true(bool(yarn_buy.get_meta("image2_daily_task_progress_shop_target", false)), "daily task yarn route should mark yarn buy button as target")
	var yarn_frame: Control = _assert_control(instance, "ShopYarnTrapKitBuyButtonFrame", "daily task yarn route should show yarn buy plate")
	if yarn_frame != null:
		_assert_true(bool(yarn_frame.get_meta("image2_daily_task_progress_shop_target", false)), "daily task yarn route should mark yarn buy plate as target")

	_assert_manifest_entry("daily_task_progress_shop_guidance_design_reference", SHOP_GUIDANCE_REFERENCE_PATH)
	_assert_manifest_entry("daily_task_progress_shop_guidance_badge_source", SHOP_GUIDANCE_SOURCE_PATH)
	_assert_manifest_entry("daily_task_progress_shop_guidance_badge", SHOP_GUIDANCE_BADGE_PATH)

	instance.queue_free()
	_finish()


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
		print("DAILY TASK PROGRESS SHOP GUIDANCE TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("DAILY TASK PROGRESS SHOP GUIDANCE TESTS FAIL: %d" % _failures.size())
		quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			_failures.append("failed to clear daily task progress shop guidance test save: %s" % error)
