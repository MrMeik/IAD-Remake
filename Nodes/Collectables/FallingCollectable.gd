extends CharacterBody2D

class_name FallingCollectable

signal on_click(value: int)

@onready var _despawn_timer = $DepawnTimer
@onready var _collider = $CollisionShape2D
@export var _click_value = 35

var is_falling = true

func _ready():
	velocity = Vector2(0, 20)

func _physics_process(delta):
	if(is_falling):
		if(move_and_slide()):
			is_falling = false
			_despawn_timer.start()

func _on_depawn_timer_timeout():
	queue_free()

func _on_button_button_down():	
	on_click.emit(_click_value)
	queue_free()
