extends Area2D

class_name FishFood

const SPEED: float = 30

func _ready() -> void:
	$Timer.start(randf_range(1, 5))

func _physics_process(delta: float) -> void:
	position += transform.y * SPEED * delta

func _on_timer_timeout() -> void:
	queue_free()
