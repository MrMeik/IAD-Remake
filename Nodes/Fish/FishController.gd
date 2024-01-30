extends CharacterBody2D

class_name FishController

@export var food_source: Node2D
@onready var _animation_player = $AnimationPlayer
@onready var _sprite = $Sprite2D
@onready var _mouth = $Mouth
@onready var _mouth_collider: CollisionShape2D = $Mouth/MouthCollider
@onready var _movement_cooldown_timer = $MovementCooldownTimer
@onready var _move_in_direction_timer = $MoveInDirectionTimer
@onready var _hunger_timer = $HungerTimer
@onready var _hunger_color_shift_timer = $HungerColorShiftTimer
@onready var _hunger_death_timer = $HungerDeathTimer

@onready var _normal_texture: Texture2D = load("res://Sprites/Fish/Large_Goldfish.png")
@onready var _hungry_texture: Texture2D = load("res://Sprites/Fish/Large_Goldfish_Hungry.png")

const RESTRICTED_ANGLE: float = 55
const MOVE_WIDTH: float = 30;
const MAX_SPEED: float = 60;
const IDLE_SPEED: float = 2;

var track_position: Vector2 = Vector2.ZERO
var previous_target_delta: Vector2 = Vector2.ZERO
var is_hungry: bool = false

var is_turning: bool = false
var allow_passive_move: bool = true
var can_move: bool = true

var facing_left: bool = false

var passive_movement_vector: Vector2 = Vector2.ZERO

@export var ai_disabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_animation_player.play("swim_right")
	_hunger_timer.start(8) #Fish will become hungry after 8 seconds	
	_sprite.texture = _normal_texture
	_mouth_collider.disabled = true
	facing_left = false
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (ai_disabled):
		move_and_slide()
		return
	
	if (!can_move):
		velocity = passive_movement_vector.normalized() * IDLE_SPEED
		move_and_slide()
		return

	#velocity = (get_global_mouse_position() - position).normalized() * MAX_SPEED

	var is_targeting_food: bool = false
	if (is_hungry):
		var food_options: Array[Node] = food_source.get_children()
		if (food_options.size() > 0): 			
			is_targeting_food = true
			var food_target = determine_closest_food_target(food_options)
			if (move_to_target(food_target, delta)):				
				pass
				
	if (!is_targeting_food):
		if (allow_passive_move):
			passive_movement_vector = get_random_movement_direction()
			allow_passive_move = false
			_move_in_direction_timer.start(randf_range(3, 6))
		velocity = passive_movement_vector
	#
	move_and_slide();
	
	# Check to see if direction has flipped, need to change animation
	if (!is_turning and velocity.x != 0 and _is_facing_oppisite_of_travel()):
		if (facing_left):			
			_animation_player.play_backwards("turn_r_to_l")
		else:
			_animation_player.play("turn_r_to_l")
		is_turning = true

func _is_facing_oppisite_of_travel():
	return (sign(velocity.x) == 1 and facing_left) or (sign(velocity.x) == -1 and !facing_left)

func get_random_movement_direction() -> Vector2:
	#TODO: Make more random
	var angle = EXTREME_ANGLES[randi() % 4]
	var speed = randf_range(5, 12)
	
	return angle * speed

func move_to_target(target: Vector2, delta: float) -> bool:	
	var mouth_position = _mouth.global_position
	var target_delta = target - mouth_position
	var remaining_distance = target_delta.length();
	if (remaining_distance < 1):
		velocity = Vector2.ZERO
		previous_target_delta = Vector2.ZERO
		return true		
	
	if (remaining_distance < 5):
		velocity = target_delta.normalized() * MAX_SPEED
		previous_target_delta = Vector2.ZERO		
		
	var target_direction = new_determine_clamped_target_direction(target_delta, previous_target_delta)
	previous_target_delta = target_direction
	var new_velocity = velocity.slerp(target_direction * MAX_SPEED, .25)
		
	var new_position = mouth_position + new_velocity * delta 	
	var new_target_delta = target - new_position	
	
	var has_crossed = target_delta.dot(new_target_delta) < 0
	
	velocity = new_velocity	
	return has_crossed
	
var EXTREME_ANGLES = [
	Vector2.from_angle(deg_to_rad(90 - RESTRICTED_ANGLE)),
	Vector2.from_angle(deg_to_rad(90 + RESTRICTED_ANGLE)),
	Vector2.from_angle(deg_to_rad(270 - RESTRICTED_ANGLE)),
	Vector2.from_angle(deg_to_rad(270 + RESTRICTED_ANGLE))
]

func new_determine_clamped_target_direction(vector_to_target: Vector2, last_target_direction: Vector2) -> Vector2:
	var normalized_delta = vector_to_target.normalized()
	
	if (is_direction_valid(normalized_delta)):
		return normalized_delta
	
	if (abs(vector_to_target.x) > MOVE_WIDTH):
		# Outside of central column, travel in whichever extreme angle is closest to the target direction
		return get_closest_extreme_angle(vector_to_target)
	else:
		# Inside central column
		if (last_target_direction in EXTREME_ANGLES):
			# If already moving along extreme angle, continue
			return last_target_direction
		else:
			# If not moving at extreme angle, find extreme angle to move at towards target
			return get_closest_extreme_angle(vector_to_target)

func get_closest_extreme_angle(direction: Vector2) -> Vector2:
	for ang in EXTREME_ANGLES:
		if (sign(ang.x) == sign(direction.x) &&  sign(ang.y) == sign(direction.y)):
			return ang
	return Vector2.ZERO
	
func is_direction_valid(direction: Vector2) -> bool:
	var angle = rad_to_deg(direction.angle())
	return abs(90 - abs(angle)) > RESTRICTED_ANGLE
	
func determine_closest_food_target(food_options: Array[Node]) -> Vector2:
	var min_distance: float = 1000000000
	var min_node: Node2D = food_options[0]
	var mouth_position = _mouth.global_position
	
	for child in food_source.get_children():
		var distance_to: float = mouth_position.distance_squared_to((child as Node2D).position)
		if (distance_to < min_distance):
			min_distance = distance_to
			min_node = child as Node2D	
	return min_node.position

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "turn_r_to_l"):
		is_turning = false
		if (_sprite.region_rect.position.x == 0):
			_animation_player.play("swim_right")
			facing_left = false
		else:
			_animation_player.play("swim_left")
			facing_left = true

func _on_mouth_area_entered(area: Area2D) -> void:
	# Eat the food
	if (area is FishFood):
		var food: FishFood = area
		area.queue_free()
		is_hungry = false
		_mouth_collider.set_deferred("disabled", true)
		_sprite.texture = _normal_texture
		_hunger_death_timer.stop()
		_hunger_color_shift_timer.stop()
		_hunger_timer.start(food.food_hunger_timeout)

func _on_movement_cooldown_timer_timeout() -> void:
	allow_passive_move = true

func _on_move_in_direction_timer_timeout() -> void:
	# Once moved in direction for sufficient amount of time, stop moving for a while
	allow_passive_move = false	
	_movement_cooldown_timer.start(randf_range(1, 6))
	passive_movement_vector = passive_movement_vector.normalized() * IDLE_SPEED

# Timers related to being hungry / dying from hunger
func _on_hunger_timer_timeout() -> void:
	is_hungry = true
	_mouth_collider.disabled = false
	_hunger_color_shift_timer.start()
	_hunger_death_timer.start()

func _on_hunger_color_shift_timer_timeout() -> void:
	# Recolor fish to be green (he's hungry)
	_sprite.texture = _hungry_texture
	pass # Replace with function body.

func _on_hunger_death_timer_timeout() -> void:
	# Fish will now die
	# TODO: Play starve animation and persist body for a bit
	queue_free()


func _on_buy_goldfish_button_purchase_request(price: int) -> void:
	pass # Replace with function body.
