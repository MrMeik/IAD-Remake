extends Node2D

class_name FallingCollectable

signal on_click(value: int)

@onready var _collider = $CollisionShape2D
@export var _click_value = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		on_click.emit(_click_value)
		queue_free()
