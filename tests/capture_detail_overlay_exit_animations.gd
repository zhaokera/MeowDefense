extends SceneTree

const OUT_DIR := "/Users/zhaok/cat/artifacts"
const TEST_SAVE_PATH := "user://meow_defense_detail_overlay_exit_animation_capture_save.json"


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
	if instance == null:
		push_error("main scene should instantiate")
		quit(1)
		return
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame
	await process_frame

	if not await _capture_album_entry_detail_exit(instance):
		return
	if not await _capture_backpack_item_detail_exit(instance):
		return
	if not await _capture_achievement_progress_guidance_exit(instance):
		return

	instance.queue_free()
	_clear_save_file()
	quit(0)


func _capture_album_entry_detail_exit(instance: Node) -> bool:
	var album_button: Button = instance.find_child("AlbumButton", true, false) as Button
	if album_button == null:
		push_error("AlbumButton missing")
		quit(1)
		return false
	album_button.emit_signal("pressed")
	await process_frame
	var inspect_button: Button = instance.find_child("AlbumTowerInspectButton", true, false) as Button
	if inspect_button == null:
		push_error("AlbumTowerInspectButton missing")
		quit(1)
		return false
	inspect_button.emit_signal("pressed")
	await process_frame
	await process_frame
	return await _capture_overlay_exit(
		instance,
		"AlbumEntryDetailOverlay",
		"CloseAlbumEntryDetailButton",
		"album_entry_detail_exit_animation.png"
	)


func _capture_backpack_item_detail_exit(instance: Node) -> bool:
	instance.call("_show_main_menu")
	await process_frame
	await process_frame
	instance.set("_total_fish", 60)
	instance.set("_paw_tokens", 3)
	instance.set("_yarn_traps", 2)
	var backpack_button: Button = instance.find_child("BottomBagButton", true, false) as Button
	if backpack_button == null:
		push_error("BottomBagButton missing")
		quit(1)
		return false
	backpack_button.emit_signal("pressed")
	await process_frame
	var item_button: Button = instance.find_child("BackpackYarnTrapItemButton", true, false) as Button
	if item_button == null:
		push_error("BackpackYarnTrapItemButton missing")
		quit(1)
		return false
	item_button.emit_signal("pressed")
	await process_frame
	await process_frame
	return await _capture_overlay_exit(
		instance,
		"BackpackItemDetailOverlay",
		"CloseBackpackItemDetailButton",
		"backpack_item_detail_exit_animation.png"
	)


func _capture_achievement_progress_guidance_exit(instance: Node) -> bool:
	instance.call("_show_main_menu")
	await process_frame
	await process_frame
	var achievements_button: Button = instance.find_child("BottomAchievementsButton", true, false) as Button
	if achievements_button == null:
		push_error("BottomAchievementsButton missing")
		quit(1)
		return false
	achievements_button.emit_signal("pressed")
	await process_frame
	var row_button: Button = instance.find_child("AchievementFirstClearButton", true, false) as Button
	if row_button == null:
		push_error("AchievementFirstClearButton missing")
		quit(1)
		return false
	row_button.emit_signal("pressed")
	await process_frame
	await process_frame
	return await _capture_overlay_exit(
		instance,
		"AchievementProgressGuidanceOverlay",
		"CloseAchievementProgressGuidanceButton",
		"achievement_progress_guidance_exit_animation.png"
	)


func _capture_overlay_exit(instance: Node, overlay_name: String, close_button_name: String, file_name: String) -> bool:
	var overlay: Control = instance.find_child(overlay_name, true, false) as Control
	var close_button: Button = instance.find_child(close_button_name, true, false) as Button
	if overlay == null or close_button == null:
		push_error("%s or %s missing" % [overlay_name, close_button_name])
		quit(1)
		return false
	for _frame: int in range(12):
		await process_frame

	Engine.time_scale = 0.04
	close_button.emit_signal("pressed")
	await process_frame
	if not bool(overlay.get_meta("image2_overlay_exit_animation", false)):
		push_error("%s should mark Image2 exit animation" % overlay_name)
		Engine.time_scale = 1.0
		quit(1)
		return false
	if not is_instance_valid(overlay):
		push_error("%s should remain visible during slowed exit animation" % overlay_name)
		Engine.time_scale = 1.0
		quit(1)
		return false
	await RenderingServer.frame_post_draw

	var image: Image = root.get_texture().get_image()
	if image == null:
		push_error("failed to read viewport image")
		Engine.time_scale = 1.0
		quit(1)
		return false
	var output_path := "%s/%s" % [OUT_DIR, file_name]
	var error: Error = image.save_png(output_path)
	if error != OK:
		push_error("failed to save %s: %s" % [output_path, error])
		Engine.time_scale = 1.0
		quit(1)
		return false
	print("CAPTURED %s" % output_path)
	Engine.time_scale = 1.0
	if is_instance_valid(overlay):
		overlay.queue_free()
	await process_frame
	return true


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
