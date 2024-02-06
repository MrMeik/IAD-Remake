extends Node2D

class_name CollectableSpawner

@onready var _gui: GuiController = $"../GUI"

func register_collectable(collectable: FallingCollectable) -> void:
	add_child(collectable)
	collectable.on_click.connect(on_collectable_click)

func on_collectable_click(collectable: FallingCollectable) -> void:
	_gui.update_price(collectable.click_value)
