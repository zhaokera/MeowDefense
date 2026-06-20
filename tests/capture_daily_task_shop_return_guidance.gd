extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/daily_task_shop_return_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_daily_task_shop_return_guidance_capture_save.json"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		push_error("main scene should load")
		quit(1)
		return
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	instance.set("_reward_date_override", "2026-06-20")
	root.add_child(instance)
	await process_frame

	instance.set("_shop_starter_claimed", true)
	instance.set("_total_fish", 0)
	instance.set("_best_stars_by_level", {1: 3})
	instance.call("_recalculate_best_stars")
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var shortage: Button = instance.find_child("ShopYarnTrapKitShortageButton", true, false) as Button
	if shortage == null:
		push_error("ShopYarnTrapKitShortageButton missing")
		quit(1)
		return
	shortage.emit_signal("pressed")
	await process_frame

	var tasks_action: Button = instance.find_child("GoDailyTaskFromShopShortageButton", true, false) as Button
	if tasks_action == null:
		push_error("GoDailyTaskFromShopShortageButton missing")
		quit(1)
		return
	tasks_action.emit_signal("pressed")
	await _wait_until_exists(instance, "DailyTaskOverlay")

	var claim: Button = instance.find_child("ClaimDailyTaskFirstClearButton", true, false) as Button
	if claim == null:
		push_error("ClaimDailyTaskFirstClearButton missing")
		quit(1)
		return
	claim.emit_signal("pressed")
	await _wait_until_exists(instance, "DailyTaskShopReturnGuidance")
	for _frame: int in range(36):
		await process_frame
	await RenderingServer.frame_post_draw

	var route_button: Button = instance.find_child("DailyTaskShopReturnButton", true, false) as Button
	if route_button == null:
		push_error("DailyTaskShopReturnButton missing")
		quit(1)
		return
	var label: Label = instance.find_child("DailyTaskShopReturnLabel", true, false) as Label
	if label == null or not label.text.contains("商店"):
		push_error("DailyTaskShopReturnLabel missing expected copy")
		quit(1)
		return

	var viewport_texture: ViewportTexture = root.get_texture()
	if viewport_texture == null:
		push_error("failed to read viewport texture")
		quit(1)
		return
	var image: Image = viewport_texture.get_image()
	if image == null:
		push_error("failed to read viewport image")
		quit(1)
		return
	var result: Error = image.save_png(OUT_PATH)
	if result != OK:
		push_error("failed to save screenshot: %s" % result)
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	instance.queue_free()
	_clear_save_file()
	quit(0)


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 240) -> void:
	for _frame: int in range(max_frames):
		if root_node.find_child(node_name, true, false) != null:
			return
		await process_frame


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear daily task shop-return guidance capture save: %s" % error)
