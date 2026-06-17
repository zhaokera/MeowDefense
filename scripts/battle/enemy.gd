extends Node2D
class_name CatDefenseEnemy

const ENEMY_HEALTH_BAR_UNDER := preload("res://assets/generated/ui/enemy_health_bar_under.png")
const ENEMY_HEALTH_BAR_FILL := preload("res://assets/generated/ui/enemy_health_bar_fill.png")
const ENEMY_HEALTH_BAR_DANGER_FILL := preload("res://assets/generated/ui/enemy_health_bar_danger_fill.png")
const ENEMY_FALLBACK_SHEET := preload("res://assets/generated/enemies/mouse_basic_sheet.png")
const ENEMY_HEALTH_BAR_ROOT_POS := Vector2(-58, -62)
const ENEMY_HEALTH_BAR_FRAME_SIZE := Vector2(116, 25)
const ENEMY_HEALTH_BAR_FILL_POS := Vector2(22, 6)
const ENEMY_HEALTH_BAR_FILL_SIZE := Vector2(73, 12)

signal defeated(enemy: Node2D)
signal reached_goal(enemy: Node2D)

var enemy_id: String = ""
var display_name: String = ""
var max_hp: float = 1.0
var hp: float = 1.0
var speed: float = 60.0
var reward: int = 0
var base_damage: int = 1
var texture_path: String = ""
var accent: Color = Color(0.64, 0.46, 0.36)
var reached_base: bool = false

var _path_points: Array[Vector2] = []
var _target_index: int = 1
var _visual_root: Node2D
var _sprite: Sprite2D
var _hp_bar_root: Control
var _hp_bar_frame: TextureRect
var _hp_bar: TextureProgressBar
var _visual_time: float = 0.0
var _hit_flash_timer: float = 0.0
var _slow_timer: float = 0.0
var _slow_multiplier: float = 1.0
var _sprite_frame: int = 0
var _uses_sprite_sheet: bool = false
var _walk_distance: float = 0.0


func _ready() -> void:
	_apply_visuals()
	_update_hp_bar()


func configure(data: Dictionary, points: Array) -> void:
	enemy_id = str(data.get("id", "enemy"))
	display_name = str(data.get("name", enemy_id))
	max_hp = max(1.0, float(data.get("max_hp", 1)))
	hp = max_hp
	speed = float(data.get("speed", 60.0))
	reward = int(data.get("reward", 0))
	base_damage = int(data.get("damage", 1))
	texture_path = str(data.get("texture", ""))
	if data.has("accent"):
		accent = data["accent"] as Color
	_path_points.clear()
	for point: Variant in points:
		if point is Vector2:
			_path_points.append(point as Vector2)
	_target_index = 1
	reached_base = false
	if not _path_points.is_empty():
		global_position = _path_points[0]
	_walk_distance = 0.0
	if is_inside_tree():
		_apply_visuals()
		_update_hp_bar()


func advance_along_path(delta: float) -> void:
	if reached_base or is_defeated() or _path_points.size() <= 1:
		return

	var effective_speed: float = speed * (_slow_multiplier if _slow_timer > 0.0 else 1.0)
	var remaining: float = effective_speed * delta
	while remaining > 0.0 and not reached_base:
		var target: Vector2 = _path_points[_target_index]
		var distance: float = global_position.distance_to(target)
		if distance <= 0.001:
			_advance_target()
			continue

		var step: float = min(remaining, distance)
		global_position = global_position.move_toward(target, step)
		_walk_distance += step
		remaining -= step

		if step >= distance - 0.001:
			_advance_target()


func take_damage(amount: float) -> void:
	if reached_base or is_defeated():
		return
	hp = max(0.0, hp - amount)
	_hit_flash_timer = 0.18
	_set_sprite_frame(1)
	_update_hp_bar()
	_pulse_hp_bar()
	if is_defeated():
		_set_sprite_frame(3)
		defeated.emit(self)


func is_defeated() -> bool:
	return hp <= 0.0


func _process(delta: float) -> void:
	_update_animation(delta)


func apply_slow(multiplier: float, duration: float) -> void:
	_slow_multiplier = clamp(multiplier, 0.2, 1.0)
	_slow_timer = max(_slow_timer, duration)


func has_animation_support() -> bool:
	return _visual_root != null and _sprite != null


func _advance_target() -> void:
	if _target_index >= _path_points.size() - 1:
		reached_base = true
		global_position = _path_points[_path_points.size() - 1]
		reached_goal.emit(self)
		return
	_target_index += 1


func _apply_visuals() -> void:
	if _visual_root == null:
		_visual_root = Node2D.new()
		_visual_root.name = "AnimatedEnemyVisual"
		add_child(_visual_root)
	if _sprite == null:
		_sprite = Sprite2D.new()
		_sprite.centered = true
		_visual_root.add_child(_sprite)
	if _hp_bar_root == null:
		_hp_bar_root = Control.new()
		_hp_bar_root.name = "EnemyHealthBarRoot"
		_hp_bar_root.position = ENEMY_HEALTH_BAR_ROOT_POS
		_hp_bar_root.size = ENEMY_HEALTH_BAR_FRAME_SIZE
		_hp_bar_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_hp_bar_root)
	if _hp_bar_frame == null:
		_hp_bar_frame = TextureRect.new()
		_hp_bar_frame.name = "EnemyHealthBarFrame"
		_hp_bar_frame.position = Vector2.ZERO
		_hp_bar_frame.size = ENEMY_HEALTH_BAR_FRAME_SIZE
		_hp_bar_frame.texture = ENEMY_HEALTH_BAR_UNDER
		_hp_bar_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_hp_bar_frame.stretch_mode = TextureRect.STRETCH_SCALE
		_hp_bar_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_hp_bar_root.add_child(_hp_bar_frame)
	if _hp_bar == null:
		_hp_bar = TextureProgressBar.new()
		_hp_bar.name = "EnemyHealthBar"
		_hp_bar.position = ENEMY_HEALTH_BAR_FILL_POS
		_hp_bar.size = ENEMY_HEALTH_BAR_FILL_SIZE
		_hp_bar.min_value = 0.0
		_hp_bar.max_value = 1.0
		_hp_bar.step = 0.001
		_hp_bar.value = 1.0
		_hp_bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
		_hp_bar.nine_patch_stretch = true
		_hp_bar.texture_progress = ENEMY_HEALTH_BAR_FILL
		_hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_hp_bar_root.add_child(_hp_bar)

	if not texture_path.is_empty() and ResourceLoader.exists(texture_path):
		_sprite.texture = load(texture_path)
		_uses_sprite_sheet = texture_path.ends_with("_sheet.png")
	else:
		_sprite.texture = ENEMY_FALLBACK_SHEET
		_uses_sprite_sheet = true
	_sprite.region_enabled = _uses_sprite_sheet
	_set_sprite_frame(0)
	_apply_sprite_scale()


func _update_animation(delta: float) -> void:
	_visual_time += delta
	if _slow_timer > 0.0:
		_slow_timer = max(0.0, _slow_timer - delta)
	if _hit_flash_timer > 0.0:
		_hit_flash_timer = max(0.0, _hit_flash_timer - delta)
		if _sprite != null:
			_sprite.modulate = Color(1.0, 0.55, 0.45)
	elif _sprite != null:
		_sprite.modulate = Color(0.72, 0.86, 1.0) if _slow_timer > 0.0 else Color.WHITE

	if _visual_root != null:
		var bob: float = sin(_visual_time * 9.0) * 2.0
		var squash: float = 1.0 + sin(_visual_time * 12.0) * 0.035
		_visual_root.position = Vector2(0, bob)
		_visual_root.scale = Vector2(1.0 + (1.0 - squash) * 0.5, squash)
	if _hit_flash_timer <= 0.0 and not is_defeated():
		_set_sprite_frame(_walk_frame())


func _walk_frame() -> int:
	if not _uses_sprite_sheet:
		return 0
	return 2 if int(_walk_distance / 9.0) % 2 == 1 else 0


func _set_sprite_frame(frame: int) -> void:
	_sprite_frame = frame
	if _sprite == null or _sprite.texture == null or not _uses_sprite_sheet:
		return
	var texture_size: Vector2 = _sprite.texture.get_size()
	var frame_size: Vector2 = texture_size / 2.0
	var column: int = frame % 2
	var row: int = frame / 2
	_sprite.region_rect = Rect2(Vector2(column, row) * frame_size, frame_size)


func _apply_sprite_scale() -> void:
	if _sprite == null or _sprite.texture == null:
		return
	var texture_size: Vector2 = _sprite.texture.get_size()
	var frame_size: Vector2 = texture_size / 2.0 if _uses_sprite_sheet else texture_size
	var desired_height: float = 54.0 if enemy_id != "rat_tank" else 68.0
	var ratio: float = desired_height / max(1.0, frame_size.y)
	_sprite.scale = Vector2(ratio, ratio)


func _update_hp_bar() -> void:
	if _hp_bar == null:
		return
	var ratio: float = clamp(hp / max_hp, 0.0, 1.0)
	_hp_bar.value = ratio
	_hp_bar.texture_progress = ENEMY_HEALTH_BAR_FILL if ratio > 0.4 else ENEMY_HEALTH_BAR_DANGER_FILL


func _pulse_hp_bar() -> void:
	if _hp_bar_root == null:
		return
	_hp_bar_root.pivot_offset = _hp_bar_root.size * 0.5
	_hp_bar_root.scale = Vector2(1.08, 1.08)
	var tween: Tween = create_tween()
	tween.tween_property(_hp_bar_root, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
