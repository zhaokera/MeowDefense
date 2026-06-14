extends Area2D
class_name CatDefenseBuildSlot

signal clicked(slot: CatDefenseBuildSlot)

var occupied: bool = false
var slot_radius: float = 44.0

var _shape: CollisionShape2D


func _ready() -> void:
	input_pickable = true
	z_index = 4
	if _shape == null:
		_shape = CollisionShape2D.new()
		var circle: CircleShape2D = CircleShape2D.new()
		circle.radius = slot_radius
		_shape.shape = circle
		add_child(_shape)
	input_event.connect(_on_input_event)
	queue_redraw()


func set_occupied(value: bool) -> void:
	occupied = value
	queue_redraw()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(self)
	elif event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			clicked.emit(self)


func _draw() -> void:
	var fill: Color = Color(1.0, 0.93, 0.66, 0.78) if not occupied else Color(0.45, 0.35, 0.24, 0.35)
	var stroke: Color = Color(0.55, 0.31, 0.12, 0.8)
	draw_circle(Vector2.ZERO, slot_radius, fill)
	draw_arc(Vector2.ZERO, slot_radius, 0.0, TAU, 48, stroke, 3.0)
	if not occupied:
		draw_line(Vector2(-12, 0), Vector2(12, 0), stroke, 3.0)
		draw_line(Vector2(0, -12), Vector2(0, 12), stroke, 3.0)
		draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.76, 0.25, 0.72))
