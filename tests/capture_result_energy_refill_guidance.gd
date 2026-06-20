extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/result_energy_refill_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_result_energy_refill_guidance_capture_save.json"


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
	instance.set("_reward_date_override", "2026-06-20")
	instance.set("_energy_refilled_on", "2026-06-20")
	instance.set("_max_energy", 15)
	instance.set("_energy", 0)
	instance.set("_total_fish", 25)
	instance.set("_current_level_id", 1)
	instance.set("_unlocked_level", 2)
	instance.set("_claimed_achievements", {"first_clear": true})
	root.add_child(instance)
	await process_frame
	instance.set("_energy_refilled_on", "2026-06-20")
	instance.set("_energy", 0)
	instance.call("_show_result", true, 3, 0)
	await process_frame

	var next_button: Button = instance.find_child("NextLevelButton", true, false) as Button
	if next_button == null or next_button.disabled:
		push_error("NextLevelButton missing or disabled")
		quit(1)
		return
	next_button.emit_signal("pressed")
	await _wait_until_exists(instance, "ResultEnergyRefillGuidance")
	for _frame: int in range(60):
		await process_frame

	var guidance: Control = instance.find_child("ResultEnergyRefillGuidance", true, false) as Control
	if guidance == null:
		push_error("ResultEnergyRefillGuidance missing")
		quit(1)
		return
	var route_button: Button = instance.find_child("ResultEnergyRefillButton", true, false) as Button
	if route_button == null:
		push_error("ResultEnergyRefillButton missing")
		quit(1)
		return
	var label: Label = instance.find_child("ResultEnergyRefillLabel", true, false) as Label
	if label == null or not label.text.contains("体力"):
		push_error("ResultEnergyRefillLabel missing expected copy")
		quit(1)
		return

	await RenderingServer.frame_post_draw
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
	var error: Error = image.save_png(OUT_PATH)
	if error != OK:
		push_error("failed to save %s: %s" % [OUT_PATH, error])
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
			push_error("failed to clear result energy refill guidance capture save: %s" % error)
