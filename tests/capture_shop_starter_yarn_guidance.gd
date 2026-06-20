extends SceneTree

const OUT_PATH := "/Users/zhaok/cat/artifacts/shop_starter_yarn_guidance.png"
const TEST_SAVE_PATH := "user://meow_defense_shop_starter_yarn_guidance_capture_save.json"


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
	instance.set("_total_fish", 10)
	instance.set("_shop_starter_claimed", false)
	root.add_child(instance)
	await process_frame

	instance.call("_show_shop_overlay", instance.find_child("MainMenuScreen", true, false))
	await process_frame
	var starter_claim: Button = instance.find_child("ClaimShopFishPackButton", true, false) as Button
	if starter_claim == null:
		push_error("ClaimShopFishPackButton missing")
		quit(1)
		return
	starter_claim.emit_signal("pressed")
	for _frame: int in range(60):
		await process_frame

	if instance.find_child("ShopStarterYarnGuidance", true, false) == null:
		push_error("ShopStarterYarnGuidance missing")
		quit(1)
		return
	var yarn_button: Button = instance.find_child("BuyShopYarnTrapKitButton", true, false) as Button
	if yarn_button == null or yarn_button.disabled:
		push_error("BuyShopYarnTrapKitButton should be enabled after starter fish")
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


func _clear_save_file() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
		if error != OK:
			push_error("failed to clear shop starter yarn guidance capture save: %s" % error)
