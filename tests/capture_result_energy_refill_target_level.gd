extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/result_energy_refill_target_level.png"
const TEST_SAVE_PATH := "user://meow_defense_result_energy_refill_target_level_capture_save.json"


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
	if next_button == null:
		push_error("NextLevelButton missing")
		quit(1)
		return
	next_button.emit_signal("pressed")
	await _wait_until_exists(instance, "ResultEnergyRefillButton")
	var result_refill: Button = instance.find_child("ResultEnergyRefillButton", true, false) as Button
	if result_refill == null:
		push_error("ResultEnergyRefillButton missing")
		quit(1)
		return
	result_refill.emit_signal("pressed")
	await _wait_until_exists(instance, "BuyShopEnergyRefillButton")

	var buy_button: Button = instance.find_child("BuyShopEnergyRefillButton", true, false) as Button
	if buy_button == null:
		push_error("BuyShopEnergyRefillButton missing")
		quit(1)
		return
	buy_button.emit_signal("pressed")
	await _wait_until_exists(instance, "ShopEnergyRefillReturnButton")

	var return_button: Button = instance.find_child("ShopEnergyRefillReturnButton", true, false) as Button
	if return_button == null:
		push_error("ShopEnergyRefillReturnButton missing")
		quit(1)
		return
	return_button.emit_signal("pressed")
	await _wait_until_exists(instance, "Level2EnergyReadyGuidance")
	for _frame: int in range(45):
		await process_frame

	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
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


func _wait_until_exists(root_node: Node, node_name: String, max_frames: int = 300) -> void:
	for _frame: int in range(max_frames):
		if root_node.find_child(node_name, true, false) != null:
			return
		await process_frame


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear result energy refill target level capture save: %s" % error)
