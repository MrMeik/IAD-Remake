extends Node2D

@onready var _gui: GuiController = $"../GUI"
@onready var _food: Node2D = $food

@export var flake_food: PackedScene
@export var green_puff_food: PackedScene
@export var pill_food: PackedScene

@export var max_food_alive: int = 10

@onready var _food_to_spawn: PackedScene = flake_food

# Should probably depend on what the food max amount is
@export var placement_timeout: float = 0.25 #seconds

const FOOD_PRICE = 5

var _current_timeout: float = 0
var _is_trying_to_place: bool = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (_is_trying_to_place):
		# Decrease timeount until next food can be placed
		if (_current_timeout > 0):
			_current_timeout -= delta
			
		# Check if ready to place next pellet
		if (can_place_new_pellet()):						
			var cursor_position: Vector2 = get_global_mouse_position()			
			if (is_cursor_out_of_bounds(cursor_position)):
				return # Can't place food out of bounds
			
			var inst: FishFood = _food_to_spawn.instantiate()
			_food.add_child(inst)
			inst.position = cursor_position
			
			# Add current_timeout which may be negatrive to next timeout to account for render timing differences
			_current_timeout = placement_timeout + _current_timeout
			
			_gui.update_price(-FOOD_PRICE)
	else:
		# Reset the timeout when letting go of mouse (meaning can place as fast as mouse click)
		_current_timeout = 0

func can_place_new_pellet() -> bool:
	return _current_timeout <= 0 and _food.get_children().size() < max_food_alive and _gui.can_buy(FOOD_PRICE)
	
func is_cursor_out_of_bounds(cursor_pos: Vector2) -> bool:
	return cursor_pos.y > 119 or cursor_pos.y < -75 or cursor_pos.x < -225 or cursor_pos.x > 225

func _on_button_button_down():
	_is_trying_to_place = true

func _on_button_button_up():
	_is_trying_to_place = false

func set_food_level(level: int):
	if (level == 0):
		_food_to_spawn = flake_food
	elif (level == 1):
		_food_to_spawn = green_puff_food
	elif (level == 2):
		_food_to_spawn = pill_food
	else:
		pass
