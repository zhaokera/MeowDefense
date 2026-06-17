extends Sprite2D
class_name CatDefenseProjectile

const TowerFishboneProjectileTexture := preload("res://assets/generated/effects/tower_fishbone_projectile.png")

var target: Node2D
var speed: float = 520.0
var damage: float = 0.0
var apply_damage_on_hit: bool = false


func _ready() -> void:
	texture = TowerFishboneProjectileTexture
	centered = true
	scale = Vector2(0.055, 0.055)
	z_index = 26
	_face_target()


func configure(target_enemy: Node2D, projectile_damage: float, projectile_color: Color = Color.WHITE, should_apply_damage: bool = false) -> void:
	target = target_enemy
	damage = projectile_damage
	apply_damage_on_hit = should_apply_damage
	texture = TowerFishboneProjectileTexture
	centered = true
	modulate = Color.WHITE
	_face_target()


func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target) or target.is_defeated() or target.reached_base:
		queue_free()
		return

	var distance: float = global_position.distance_to(target.global_position)
	var step: float = speed * delta
	_face_target()
	if distance <= step:
		if apply_damage_on_hit and damage > 0.0:
			target.take_damage(damage)
		queue_free()
		return
	global_position = global_position.move_toward(target.global_position, step)


func _face_target() -> void:
	if target == null or not is_instance_valid(target):
		return
	var direction: Vector2 = target.global_position - global_position
	if direction.length() > 0.001:
		rotation = direction.angle()
