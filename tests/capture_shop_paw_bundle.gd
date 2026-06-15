extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/shop_paw_bundle_purchase.png"
const TEST_SAVE_PATH := "user://meow_defense_shop_paw_bundle_capture_save.json"


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

	instance.set("_total_fish", 80)
	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var buy_button: Button = instance.find_child("BuyShopPawBundleButton", true, false) as Button
	if buy_button == null:
		push_error("BuyShopPawBundleButton missing")
		quit(1)
		return
	buy_button.emit_signal("pressed")
	for i: int in range(16):
		await process_frame

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


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear paw bundle capture save: %s" % error)
