extends CharacterBody2D

@export var food_source: Node2D

const RESTRICTED_ANGLE: float = 55
const MOVE_WIDTH: float = 15;
const MAX_SPEED: float = 15;

enum TargetMode { TRACK, MOVE, WAIT, HUNGER }
enum TargetMoveUrgency { QUICK = 4, NORMAL = 2, SLOW = 1 }

var track_position: Vector2 = Vector2.ZERO
var target_mode: TargetMode = TargetMode.MOVE
var target_urgency: TargetMoveUrgency = TargetMoveUrgency.NORMAL;
var previous_target_delta: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match target_mode:
		TargetMode.MOVE:
			if (move_to_target(get_global_mouse_position(), delta)):
				target_mode = TargetMode.WAIT
				target_urgency = TargetMoveUrgency.NORMAL
			pass
		TargetMode.WAIT:
			velocity = Vector2.ZERO
			pass
		TargetMode.HUNGER: 
			var food_options: Array[Node] = food_source.get_children()
			if (food_options.size() > 0): 			
				var food_target = determine_closest_food_target(food_options)
				if (move_to_target(food_target, delta)):
					target_mode = TargetMode.WAIT	
					target_urgency = TargetMoveUrgency.NORMAL
					# Resets the hunger timer
					$HungerTimer.start(2)
				pass
	move_and_slide();

func move_to_target(target: Vector2, delta: float) -> bool:	
	var target_delta = target - position
	var remaining_distance = target_delta.length();
	if (remaining_distance < 1):
		velocity = Vector2.ZERO
		previous_target_delta = Vector2.ZERO
		return true		
	
	if (remaining_distance < 5):
		velocity = target_delta.normalized() * MAX_SPEED * target_urgency
		previous_target_delta = Vector2.ZERO		
		
	var target_direction = new_determine_clamped_target_direction(target_delta, previous_target_delta)
	previous_target_delta = target_direction
	var new_velocity = velocity.slerp(target_direction * MAX_SPEED * target_urgency, .25)
		
	var new_position = position + new_velocity * delta 	
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
	
	for child in food_source.get_children():
		var distance_to: float = position.distance_squared_to((child as Node2D).position)
		if (distance_to < min_distance):
			min_distance = distance_to
			min_node = child as Node2D
	
	return min_node.position

func _on_hunger_timer_timeout() -> void:
	target_mode = TargetMode.HUNGER	
	target_urgency = TargetMoveUrgency.QUICK
	pass
