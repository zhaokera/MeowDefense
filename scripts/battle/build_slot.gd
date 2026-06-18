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


func set_occupied(value: bool) -> void:
	occupied = value


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(self)
	elif event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			clicked.emit(self)
