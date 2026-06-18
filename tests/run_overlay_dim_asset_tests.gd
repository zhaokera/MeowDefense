extends SceneTree

const APP_SCRIPT_PATH := "res://scripts/app/main.gd"
const BATTLE_SCRIPT_PATH := "res://scripts/battle/battle_scene.gd"
const MANIFEST_PATH := "res://assets/generated/assets_manifest.json"
const DESIGN_REFERENCE_PATH := "res://assets/generated/ui/common_overlay_dim_design_reference.png"
const RUNTIME_TEXTURE_PATH := "res://assets/generated/ui/common_overlay_dim_vignette.png"

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var app_source := _read_text(APP_SCRIPT_PATH)
	var battle_source := _read_text(BATTLE_SCRIPT_PATH)
	var manifest := _read_text(MANIFEST_PATH)

	_assert_true(FileAccess.file_exists(DESIGN_REFERENCE_PATH), "common overlay dim should have an Image2 full-screen design reference")
	_assert_true(FileAccess.file_exists(RUNTIME_TEXTURE_PATH), "common overlay dim should have a project-bound Image2 runtime texture")
	_assert_true(app_source.contains("COMMON_OVERLAY_DIM_TEXTURE"), "app overlays should use the common Image2 dim texture")
	_assert_true(battle_source.contains("CommonOverlayDimTexture"), "battle overlays should use the common Image2 dim texture")
	_assert_true(not app_source.contains("ColorRect.new()"), "app overlays should not use code-drawn ColorRect dim layers")
	_assert_true(not battle_source.contains("ColorRect.new()"), "battle overlays should not use code-drawn ColorRect dim layers")
	_assert_true(manifest.contains("\"common_overlay_dim_design_reference\""), "manifest should list the common overlay design reference")
	_assert_true(manifest.contains("\"common_overlay_dim_vignette\""), "manifest should list the common overlay runtime texture")

	_finish()


func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_failures.append("%s should be readable" % path)
		return ""
	return file.get_as_text()


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("OVERLAY DIM ASSET TESTS PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("OVERLAY DIM ASSET TESTS FAIL: %d" % _failures.size())
		quit(1)
