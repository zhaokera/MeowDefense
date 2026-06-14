extends Node2D
class_name CatDefenseProjectile

var target: Node2D
var speed: float = 520.0
var damage: float = 1.0
var accent: Color = Color(1.0, 0.86, 0.36)


func configure(target_enemy: Node2D, projectile_damage: float, projectile_color: Color) -> void:
	target = target_enemy
	damage = projectile_damage
	accent = projectile_color
	queue_redraw()


func _process(delta: float) -> void:
	if target == null or target.is_defeated() or target.reached_base:
		queue_free()
		return

	var distance: float = global_position.distance_to(target.global_position)
	var step: float = speed * delta
	if distance <= step:
		target.take_damage(damage)
		queue_free()
		return
	global_position = global_position.move_toward(target.global_position, step)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 6.0, accent)
	draw_circle(Vector2.ZERO, 2.5, Color(1.0, 1.0, 1.0, 0.75))
