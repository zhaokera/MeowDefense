extends SceneTree

const SHOP_OUT_PATH := "/Users/zhaok/cat/artifacts/shop_yarn_trap_purchase.png"
const BACKPACK_OUT_PATH := "/Users/zhaok/cat/artifacts/backpack_yarn_trap_item.png"
const TEST_SAVE_PATH := "user://meow_defense_shop_yarn_capture_save.json"


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

	instance.set("_total_fish", 40)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var buy_button: Button = instance.find_child("BuyShopYarnTrapKitButton", true, false) as Button
	if buy_button == null:
		push_error("BuyShopYarnTrapKitButton missing")
		quit(1)
		return
	buy_button.emit_signal("pressed")
	await process_frame
	await process_frame
	if not _save_viewport(SHOP_OUT_PATH):
		return

	var close_shop: Button = instance.find_child("CloseShopButton", true, false) as Button
	if close_shop != null:
		close_shop.emit_signal("pressed")
		await process_frame
	var bag_button: Button = instance.find_child("BottomBagButton", true, false) as Button
	if bag_button == null:
		push_error("BottomBagButton missing")
		quit(1)
		return
	bag_button.emit_signal("pressed")
	await process_frame
	await process_frame
	if not _save_viewport(BACKPACK_OUT_PATH):
		return

	instance.queue_free()
	_clear_save_file()
	quit(0)


func _save_viewport(path: String) -> bool:
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(path)
	if error != OK:
		push_error("failed to save %s: %s" % [path, error])
		quit(1)
		return false
	print("CAPTURED %s" % path)
	return true


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear shop yarn capture save: %s" % error)
