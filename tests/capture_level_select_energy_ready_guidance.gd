extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/level_select_energy_ready_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_level_select_energy_ready_guidance_capture_save.json"


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
	instance.set("_reward_date_override", "2026-06-15")
	root.add_child(instance)
	await process_frame

	instance.set("_total_fish", 25)
	instance.set("_max_energy", 15)
	instance.set("_energy", 0)
	instance.set("_energy_refilled_on", "2026-06-15")
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var buy_button: Button = instance.find_child("BuyShopEnergyRefillButton", true, false) as Button
	if buy_button == null:
		push_error("BuyShopEnergyRefillButton missing")
		quit(1)
		return
	buy_button.emit_signal("pressed")
	await process_frame
	await process_frame
	var return_button: Button = instance.find_child("ShopEnergyRefillReturnButton", true, false) as Button
	if return_button == null:
		push_error("ShopEnergyRefillReturnButton missing")
		quit(1)
		return
	return_button.emit_signal("pressed")
	for index: int in range(45):
		await process_frame
	await create_timer(0.15).timeout

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


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear level select energy-ready guidance capture save: %s" % error)
