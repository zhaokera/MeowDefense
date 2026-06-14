extends Node2D
class_name CatDefenseTower

signal fired(tower: Node2D, target: Node2D)

var tower_id: String = ""
var display_name: String = ""
var cost: int = 0
var upgrade_cost: int = 0
var attack_range: float = 160.0
var damage: float = 4.0
var fire_interval: float = 0.6
var texture_path: String = ""
var accent: Color = Color(1.0, 0.58, 0.23)
var level: int = 1

var _cooldown: float = 0.0
var _visual_root: Node2D
var _sprite: Sprite2D
var _visual_time: float = 0.0
var _recoil_timer: float = 0.0
var _uses_sprite_sheet: bool = false
var _slow_multiplier: float = 1.0
var _slow_duration: float = 0.0


func _ready() -> void:
	_apply_visuals()


func configure(id: String, stats: Dictionary) -> void:
	tower_id = id
	display_name = str(stats.get("name", id))
	cost = int(stats.get("cost", 0))
	upgrade_cost = int(stats.get("upgrade_cost", 0))
	attack_range = float(stats.get("range", 160.0))
	damage = float(stats.get("damage", 4.0))
	fire_interval = float(stats.get("fire_interval", 0.6))
	_slow_multiplier = float(stats.get("slow_multiplier", 1.0))
	_slow_duration = float(stats.get("slow_duration", 0.0))
	texture_path = str(stats.get("texture", ""))
	if stats.has("accent"):
		accent = stats["accent"] as Color
	if is_inside_tree():
		_apply_visuals()


func tick(delta: float, enemies: Array) -> Node2D:
	_cooldown = max(0.0, _cooldown - delta)
	if _cooldown > 0.0:
		return null
	var target: Node2D = find_target(enemies)
	if target == null:
		return null
	apply_damage_to(target)
	_cooldown = fire_interval
	fired.emit(self, target)
	return target


func find_target(enemies: Array) -> Node2D:
	var best: Node2D = null
	var best_distance: float = INF
	for item: Variant in enemies:
		if not (item is Node2D):
			continue
		var enemy: Node2D = item as Node2D
		if enemy.reached_base or enemy.is_defeated():
			continue
		var distance: float = global_position.distance_to(enemy.global_position)
		if distance <= attack_range and distance < best_distance:
			best = enemy
			best_distance = distance
	return best


func apply_damage_to(enemy: Node2D) -> void:
	if enemy == null:
		return
	enemy.take_damage(damage * float(level))
	if _slow_duration > 0.0 and enemy.has_method("apply_slow"):
		enemy.call("apply_slow", _slow_multiplier, _slow_duration)
	_recoil_timer = 0.16
	_set_sprite_frame(2)


func upgrade() -> void:
	level += 1
	damage *= 1.35
	attack_range += 14.0
	fire_interval = max(0.25, fire_interval * 0.92)
	scale = Vector2.ONE * (1.0 + float(level - 1) * 0.08)
	_recoil_timer = 0.24


func _process(delta: float) -> void:
	_update_animation(delta)


func has_animation_support() -> bool:
	return _visual_root != null and _sprite != null


func _apply_visuals() -> void:
	if _visual_root == null:
		_visual_root = Node2D.new()
		_visual_root.name = "AnimatedTowerVisual"
		add_child(_visual_root)
	if _sprite == null:
		_sprite = Sprite2D.new()
		_sprite.centered = true
	if not texture_path.is_empty() and ResourceLoader.exists(texture_path):
		_sprite.texture = load(texture_path)
		_uses_sprite_sheet = texture_path.ends_with("_sheet.png")
		_sprite.region_enabled = _uses_sprite_sheet
		_set_sprite_frame(0)
		_apply_sprite_scale()
		if _sprite.get_parent() == null:
			_visual_root.add_child(_sprite)
	else:
		_sprite.texture = null
	queue_redraw()


func _update_animation(delta: float) -> void:
	_visual_time += delta
	if _recoil_timer > 0.0:
		_recoil_timer = max(0.0, _recoil_timer - delta)
	elif _uses_sprite_sheet:
		_set_sprite_frame(0)
	if _visual_root != null:
		var breath: float = 1.0 + sin(_visual_time * 3.5) * 0.025
		var recoil_offset: float = -8.0 * (_recoil_timer / 0.16) if _recoil_timer > 0.0 else 0.0
		_visual_root.position = Vector2(recoil_offset, sin(_visual_time * 4.0) * 1.5)
		_visual_root.scale = Vector2(breath, breath)


func _set_sprite_frame(frame: int) -> void:
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
	var desired_height: float = 96.0
	var ratio: float = desired_height / max(1.0, frame_size.y)
	_sprite.scale = Vector2(ratio, ratio)


func _draw() -> void:
	if _sprite == null or _sprite.texture == null:
		draw_circle(Vector2.ZERO, 27.0, Color(1.0, 0.82, 0.48))
		draw_circle(Vector2.ZERO, 20.0, accent)
		draw_circle(Vector2(-8, -7), 3.0, Color(0.12, 0.08, 0.05))
		draw_circle(Vector2(8, -7), 3.0, Color(0.12, 0.08, 0.05))
		draw_line(Vector2(-10, 8), Vector2(10, 8), Color(0.35, 0.18, 0.1), 3.0)
	draw_arc(Vector2.ZERO, attack_range, 0.0, TAU, 80, Color(1.0, 0.75, 0.25, 0.13), 2.0)
