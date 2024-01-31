extends Node2D

class_name CollectableSpawner

@onready var _gui: GuiController = $"../GUI"

func register_collectable(collectable: FallingCollectable) -> void:
	add_child(collectable)
	collectable.on_click.connect(on_collectable_click)

func on_collectable_click(value: int) -> void:
	_gui.update_price(value)
