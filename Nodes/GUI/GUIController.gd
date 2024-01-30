extends Control

class_name GuiController

@onready var _button_container = $GridContainer

@onready var _goldfish_spawner: GoldfishSpawner = $"../goldfish_spawner"

var button_bar: Array[PurchaseItem] = []

var _money: int = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in _button_container.get_children():
		if node is PurchaseItem:
			var pi = node as PurchaseItem
			pi.gui_controller = self
			button_bar.append(pi)
	
func can_buy(price: int) -> bool:
	#TODO: Show error animation
	return price <= _money
	
func update_price(delta: int):
	_money = _money + delta

func _on_buy_goldfish_button_purchase_request(price: int) -> void:
	# Subtract price of purchase from money
	update_price(-price)
	
	# Spawn fish!
	_goldfish_spawner.buy_goldfish()
