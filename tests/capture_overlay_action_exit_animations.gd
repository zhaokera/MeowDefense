extends SceneTree

const TEST_SAVE_PATH := "user://meow_defense_overlay_action_exit_animation_capture_save.json"
const OUTPUTS := {
	"locked": "/Users/zhaok/cat/artifacts/locked_level_action_exit_animation.png",
	"album": "/Users/zhaok/cat/artifacts/album_detail_action_exit_animation.png",
	"backpack": "/Users/zhaok/cat/artifacts/backpack_detail_action_exit_animation.png",
	"achievement": "/Users/zhaok/cat/artifacts/achievement_guidance_action_exit_animation.png",
	"shop": "/Users/zhaok/cat/artifacts/shop_shortage_action_exit_animation.png"
}


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	_clear_save_file()
	await _capture_locked_level_action()
	await _capture_album_detail_action()
	await _capture_backpack_detail_action()
	await _capture_achievement_guidance_action()
	await _capture_shop_shortage_action()
	_clear_save_file()
	quit(0)


func _capture_locked_level_action() -> void:
	var instance: Node = await _main_instance()
	instance.call("_show_level_select")
	await process_frame
	var locked_info: Button = instance.find_child("LockedLevel2InfoButton", true, false) as Button
	if locked_info == null:
		_fail("LockedLevel2InfoButton missing")
		return
	locked_info.emit_signal("pressed")
	await process_frame
	await _wait_frames(20)
	var overlay: Control = instance.find_child("LockedLevelFeedbackOverlay", true, false) as Control
	var action: Button = instance.find_child("PlayPreviousLevelButton", true, false) as Button
	await _capture_action_state(instance, overlay, action, OUTPUTS["locked"])


func _capture_album_detail_action() -> void:
	var instance: Node = await _main_instance()
	var album_button: Button = instance.find_child("AlbumButton", true, false) as Button
	if album_button == null:
		_fail("AlbumButton missing")
		return
	album_button.emit_signal("pressed")
	await process_frame
	var inspect: Button = instance.find_child("AlbumTowerInspectButton", true, false) as Button
	if inspect == null:
		_fail("AlbumTowerInspectButton missing")
		return
	inspect.emit_signal("pressed")
	await process_frame
	await _wait_frames(20)
	var overlay: Control = instance.find_child("AlbumEntryDetailOverlay", true, false) as Control
	var action: Button = instance.find_child("AlbumEntryDetailActionButton", true, false) as Button
	await _capture_action_state(instance, overlay, action, OUTPUTS["album"])


func _capture_backpack_detail_action() -> void:
	var instance: Node = await _main_instance()
	instance.set("_yarn_traps", 2)
	instance.call("_show_backpack_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var trap_button: Button = instance.find_child("BackpackYarnTrapItemButton", true, false) as Button
	if trap_button == null:
		_fail("BackpackYarnTrapItemButton missing")
		return
	trap_button.emit_signal("pressed")
	await process_frame
	await _wait_frames(20)
	var overlay: Control = instance.find_child("BackpackItemDetailOverlay", true, false) as Control
	var action: Button = instance.find_child("BackpackItemDetailActionButton", true, false) as Button
	await _capture_action_state(instance, overlay, action, OUTPUTS["backpack"])


func _capture_achievement_guidance_action() -> void:
	var instance: Node = await _main_instance()
	instance.call("_show_achievements_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var row_button: Button = instance.find_child("AchievementFirstClearButton", true, false) as Button
	if row_button == null:
		_fail("AchievementFirstClearButton missing")
		return
	row_button.emit_signal("pressed")
	await process_frame
	await _wait_frames(20)
	var overlay: Control = instance.find_child("AchievementProgressGuidanceOverlay", true, false) as Control
	var action: Button = instance.find_child("GoLevelsFromAchievementProgressButton", true, false) as Button
	await _capture_action_state(instance, overlay, action, OUTPUTS["achievement"])


func _capture_shop_shortage_action() -> void:
	var instance: Node = await _main_instance()
	instance.set("_shop_starter_claimed", true)
	instance.set("_total_fish", 0)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var shortage: Button = instance.find_child("ShopPawBundleShortageButton", true, false) as Button
	if shortage == null:
		_fail("ShopPawBundleShortageButton missing")
		return
	shortage.emit_signal("pressed")
	await process_frame
	await _wait_frames(20)
	var overlay: Control = instance.find_child("ShopInsufficientFishOverlay", true, false) as Control
	var action: Button = instance.find_child("GoDailyTaskFromShopShortageButton", true, false) as Button
	await _capture_action_state(instance, overlay, action, OUTPUTS["shop"])


func _main_instance() -> Node:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_fail("main scene should load")
		return null
	var instance: Node = scene.instantiate()
	if instance == null:
		_fail("main scene should instantiate")
		return null
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame
	await process_frame
	return instance


func _capture_action_state(instance: Node, overlay: Control, action: Button, out_path: String) -> void:
	if instance == null or overlay == null or action == null:
		_fail("capture target missing for %s" % out_path)
		return
	Engine.time_scale = 0.04
	action.emit_signal("pressed")
	if not bool(overlay.get_meta("image2_overlay_exit_animation", false)):
		_fail("overlay should mark Image2 action exit animation for %s" % out_path)
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	if image == null:
		_fail("failed to read viewport image for %s" % out_path)
		return
	var error: Error = image.save_png(out_path)
	if error != OK:
		_fail("failed to save %s: %s" % [out_path, error])
		return
	print("CAPTURED %s" % out_path)
	Engine.time_scale = 1.0
	instance.queue_free()
	_clear_save_file()
	await process_frame


func _wait_frames(count: int) -> void:
	for _frame: int in range(count):
		await process_frame


func _fail(message: String) -> void:
	Engine.time_scale = 1.0
	push_error(message)
	_clear_save_file()
	quit(1)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
