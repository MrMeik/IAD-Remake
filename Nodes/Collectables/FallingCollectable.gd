extends CharacterBody2D

class_name FallingCollectable

signal on_click(collectable: FallingCollectable)

@onready var _sprite = $AnimatedSprite2D
@onready var _despawn_timer = $DepawnTimer
@onready var _collider = $CollisionShape2D
@onready var _button = $Control
@onready var _click_audio_player = $AudioStreamPlayer
@export var click_value = 35

var is_audio_complete = false

var is_falling = true
var is_collected = false

var speed: float = 20
var acc = 2

func _ready():
	velocity = Vector2(0, 20)

func _physics_process(delta):
	if(is_collected):		
		if (!_sprite.visible and is_audio_complete):
			queue_free()
		acc = max(1, acc * .98)
		speed = max(1000, speed * acc) * delta
		var actual_delta = (Vector2(200, -100) - global_position)		
		if (actual_delta.length() < speed):
			_sprite.visible = false	
		position = position + actual_delta.normalized() * speed
		
		return
	
	if(is_falling):
		if(move_and_slide()):
			is_falling = false
			_despawn_timer.start()

func _on_depawn_timer_timeout():
	queue_free()

func _on_button_button_down():	
	on_click.emit(self)
	_button.visible = false
	_click_audio_player.play()
	is_collected = true
	_despawn_timer.stop()

func _on_audio_stream_player_finished() -> void:
	is_audio_complete = true
