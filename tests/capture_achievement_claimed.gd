extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/achievements_claimed_overlay.png"
const TEST_SAVE_PATH := "user://meow_defense_achievement_claim_capture_save.json"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	_clear_save_file()
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		push_error("main scene missing")
		quit(1)
		return
	var instance: Node = scene.instantiate()
	instance.set("_save_path", TEST_SAVE_PATH)
	root.add_child(instance)
	await process_frame

	instance.set("_best_stars_by_level", {1: 3})
	instance.call("_recalculate_best_stars")
	instance.call("_show_achievements_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame

	var claim_button: Button = instance.find_child("AchievementFirstClearClaimButton", true, false) as Button
	if claim_button == null:
		push_error("AchievementFirstClearClaimButton missing")
		quit(1)
		return
	claim_button.emit_signal("pressed")
	await process_frame
	await process_frame

	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(OUT_PATH)
	if error != OK:
		push_error("failed to save achievement screenshot: %s" % error)
		quit(1)
		return
	print("CAPTURED %s" % OUT_PATH)
	instance.queue_free()
	_clear_save_file()
	quit(0)


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear achievement capture save: %s" % error)
