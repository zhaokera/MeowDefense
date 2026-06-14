extends Resource
class_name LevelData

var id: int = 0
var name: String = ""
var description: String = ""
var background: String = ""
var base_texture: String = ""
var base_hp: int = 10
var start_coins: int = 100
var reward_fish: int = 0
var allowed_towers: Array[String] = []
var path_points: Array[Vector2] = []
var build_slots: Array[Vector2] = []
var waves: Array[Dictionary] = []


func load_from_file(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open level config: %s" % path)
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		push_error("Level config is not a JSON object: %s" % path)
		return

	apply_dictionary(parsed as Dictionary)


func apply_dictionary(data: Dictionary) -> void:
	id = int(data.get("id", 0))
	name = str(data.get("name", ""))
	description = str(data.get("description", ""))
	background = str(data.get("background", ""))
	base_texture = str(data.get("base_texture", ""))
	base_hp = int(data.get("base_hp", 10))
	start_coins = int(data.get("start_coins", 100))
	reward_fish = int(data.get("reward_fish", 0))
	allowed_towers = _string_array(data.get("allowed_towers", []))
	path_points = _vector2_array(data.get("path_points", []))
	build_slots = _vector2_array(data.get("build_slots", []))
	waves = _dictionary_array(data.get("waves", []))


static func _string_array(raw: Variant) -> Array[String]:
	var result: Array[String] = []
	if raw is Array:
		for item: Variant in raw:
			result.append(str(item))
	return result


static func _dictionary_array(raw: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if raw is Array:
		for item: Variant in raw:
			if item is Dictionary:
				result.append((item as Dictionary).duplicate(true))
	return result


static func _vector2_array(raw: Variant) -> Array[Vector2]:
	var result: Array[Vector2] = []
	if raw is Array:
		for item: Variant in raw:
			if item is Array and (item as Array).size() >= 2:
				var point: Array = item as Array
				result.append(Vector2(float(point[0]), float(point[1])))
	return result
