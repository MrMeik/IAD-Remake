extends Area2D

class_name FishFood

const SPEED: float = 30
const BASE_GROUND: int = 122
const DESPAWN_TIME: int = 3
const HEIGHT_VARIANCE = 5

var hit_ground: bool = false
@onready var ground_height: int = BASE_GROUND + (randi() % HEIGHT_VARIANCE) - 3
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var despawn_timer: Timer = $Timer

@export var food_hunger_timeout: int = 8
@export var food_growth_amount: int = 1

func _physics_process(delta: float) -> void:
	if (!hit_ground):		
		var new_pos = position + transform.y * SPEED * delta
		if (new_pos.y > ground_height): 
			new_pos.y = ground_height
			hit_ground = true
			#Food has hit the ground, it will stop moving and despawn after 3 seconds
			sprite.speed_scale = 0
			despawn_timer.start(DESPAWN_TIME)
		position = new_pos

func _on_timer_timeout() -> void:
	queue_free()
