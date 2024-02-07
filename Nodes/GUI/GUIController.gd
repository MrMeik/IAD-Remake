extends Control

class_name GuiController

@onready var _button_container = $GridContainer
@onready var _money_display: MoneyDisplay = $MoneyDisplay
@onready var _cant_buy_sound_player: AudioStreamPlayer = $CantBuySoundPlayer

# Purchase Goldfish
@onready var _goldfish_spawner: GoldfishSpawner = $"../goldfish_spawner"

# Food Quality
@onready var _food_spawner = $"../food_spawner"
@onready var _upgrade_food_quality_button = $GridContainer/UpgradeFoodQuality
@onready var _upgrade_food_quality_texture: TextureRect = $GridContainer/UpgradeFoodQuality/TextureRect

# Purchase Egg
@onready var _egg_texture: TextureRect = $GridContainer/BuyEgg/TextureRect


var button_bar: Array[PurchaseItem] = []

var _money: int = 1000

var _egg_stage = 0
var _food_stage = 0

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
	if (!can_buy(price)):
		# Play error
		_cant_buy_sound_player.play()
		_money_display.flash_display()
		return
	# Subtract price of purchase from money
	update_price(-price)
	
	# Spawn fish!
	_goldfish_spawner.buy_goldfish()

func _on_buy_egg_purchase_request(price):
	if (!can_buy(price)):
		# Play error
		_cant_buy_sound_player.play()
		_money_display.flash_display()
		return
	update_price(-price)
	
	if(_egg_stage == 2):
		print("game win")
		get_tree().change_scene_to_file("res://Nodes/TransitionScenes/level_complete.tscn")
	else:
		_egg_stage = _egg_stage + 1
		var x_pos = 60 - 20 * _egg_stage 
		(_egg_texture.texture as AtlasTexture).region.position = Vector2(x_pos, 0)

func _on_upgrade_food_quality_purchase_request(price):
	if (!can_buy(price)):
		# Play error
		_cant_buy_sound_player.play()
		_money_display.flash_display()
		return
	update_price(-price)
	
	_food_stage = _food_stage + 1
	_food_spawner.set_food_level(_food_stage)
	
	if(_food_stage == 1):
		(_upgrade_food_quality_texture.texture as AtlasTexture).region.position = Vector2(0, 40)
	
	if(_food_stage == 2):
		_upgrade_food_quality_button.disable_item()
