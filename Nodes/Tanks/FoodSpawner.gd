extends Node2D

@export var food_to_spawn: PackedScene
@export var max_food_alive: int = 10

# Should probably depend on what the food max amount is
@export var placement_timeout: float = 0.25 #seconds

var current_timeout: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		# Decrease timeount until next food can be placed
		if (current_timeout > 0):
			current_timeout -= delta
			
		# Check if ready to place next pellet
		if (can_place_new_pellet()):						
			var cursor_position: Vector2 = get_global_mouse_position()			
			if (is_cursor_out_of_bounds(cursor_position)):
				return # Can't place food out of bounds
			
			var inst: FishFood = food_to_spawn.instantiate()
			add_child(inst)
			inst.position = cursor_position
			
			# Add current_timeout which may be negatrive to next timeout to account for render timing differences
			current_timeout = placement_timeout + current_timeout
	else:
		# Reset the timeout when letting go of mouse (meaning can place as fast as mouse click)
		current_timeout = 0

func can_place_new_pellet() -> bool:
	return current_timeout <= 0 and get_children().size() < max_food_alive 
	
func is_cursor_out_of_bounds(cursor_pos: Vector2) -> bool:
	return cursor_pos.y > 119 or cursor_pos.y < -75 or cursor_pos.x < -225 or cursor_pos.x > 225
