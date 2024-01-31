extends Control

class_name GuiController

@onready var _button_container = $GridContainer
@onready var _money_display: MoneyDisplay = $MoneyDisplay

@onready var _goldfish_spawner: GoldfishSpawner = $"../goldfish_spawner"
@onready var _egg_texture: TextureRect = $GridContainer/BuyEgg/TextureRect

var button_bar: Array[PurchaseItem] = []

var _money: int = 1000

var _egg_stage = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_money_display.update_display(_money)
	
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
	_money_display.update_display(_money)

func _on_buy_goldfish_button_purchase_request(price: int) -> void:
	# Subtract price of purchase from money
	update_price(-price)
	
	# Spawn fish!
	_goldfish_spawner.buy_goldfish()

func _on_buy_egg_purchase_request(price):
	update_price(-price)
	
	if(_egg_stage == 2):
		print("game win")
		get_tree().change_scene_to_file("res://Nodes/TransitionScenes/level_complete.tscn")
	else:
		_egg_stage = _egg_stage + 1
		var x_pos = 60 - 20 * _egg_stage 
		(_egg_texture.texture as AtlasTexture).region.position = Vector2(x_pos, 0)
