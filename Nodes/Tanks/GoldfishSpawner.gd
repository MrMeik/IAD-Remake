extends Node2D

class_name GoldfishSpawner

@onready var _goldfish: PackedScene = preload("res://Nodes/Fish/fish_base.tscn")

@onready var _food_spawner = $"../food_spawner"

var _managed_goldfish: Array[FishController] = []

func _physics_process(delta: float) -> void:
	var indicies_to_remove = []
	
	for index in range(_managed_goldfish.size()):
		var fish = _managed_goldfish[index]
		fish.velocity = fish.velocity + Vector2.UP * 15
		if (fish.velocity.y <= 0):
			fish.ai_disabled = false
			fish.set_collision_mask_value(1, true)	
			indicies_to_remove.append(index)
			
	indicies_to_remove.reverse()
			
	for index in indicies_to_remove:
		_managed_goldfish.remove_at(index)		
	
func buy_goldfish() -> void:
	var spawned_fish: FishController = _goldfish.instantiate()
	spawned_fish.set_collision_mask_value(1, false)	
	spawned_fish.ai_disabled = true
	
	var height_offset = randi() % 20
	var x_position = (randi() % 15) * 20 - 140
	spawned_fish.position = Vector2(x_position, -120 - height_offset)
	
	spawned_fish.velocity = Vector2.DOWN * 400
	spawned_fish.food_source = _food_spawner
	_managed_goldfish.append(spawned_fish)	
	add_child(spawned_fish)
