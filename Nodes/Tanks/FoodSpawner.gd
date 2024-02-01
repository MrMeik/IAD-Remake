extends Node2D

@onready var _gui: GuiController = $"../GUI"
@onready var _food: Node2D = $food

@export var food_to_spawn: PackedScene
@export var max_food_alive: int = 10

# Should probably depend on what the food max amount is
@export var placement_timeout: float = 0.25 #seconds

const FOOD_PRICE = 5

var current_timeout: float = 0
var is_trying_to_place: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (is_trying_to_place):
		# Decrease timeount until next food can be placed
		if (current_timeout > 0):
			current_timeout -= delta
			
		# Check if ready to place next pellet
		if (can_place_new_pellet()):						
			var cursor_position: Vector2 = get_global_mouse_position()			
			if (is_cursor_out_of_bounds(cursor_position)):
				return # Can't place food out of bounds
			
			var inst: FishFood = food_to_spawn.instantiate()
			_food.add_child(inst)
			inst.position = cursor_position
			
			# Add current_timeout which may be negatrive to next timeout to account for render timing differences
			current_timeout = placement_timeout + current_timeout
			
			_gui.update_price(-FOOD_PRICE)
	else:
		# Reset the timeout when letting go of mouse (meaning can place as fast as mouse click)
		current_timeout = 0

func can_place_new_pellet() -> bool:
	return current_timeout <= 0 and _food.get_children().size() < max_food_alive and _gui.can_buy(FOOD_PRICE)
	
func is_cursor_out_of_bounds(cursor_pos: Vector2) -> bool:
	return cursor_pos.y > 119 or cursor_pos.y < -75 or cursor_pos.x < -225 or cursor_pos.x > 225

func _on_button_button_down():
	is_trying_to_place = true

func _on_button_button_up():
	is_trying_to_place = false
