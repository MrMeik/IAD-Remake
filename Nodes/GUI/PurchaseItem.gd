extends TextureRect

class_name PurchaseItem

signal purchase_request(price: int)

# This needs to be assigned
@export var gui_controller: GuiController

@onready var _buy_tier_sound_player: AudioStreamPlayer = $Control/BuyTierSoundPlayer
@onready var _buy_item_sound_player: AudioStreamPlayer = $Control/BuyItemSoundPlayer
@onready var _item_price: RichTextLabel = $Control/ItemPrice
@onready var _button: Button = $Control/Button

@export var is_tier_buyable: bool = true
@export var is_enabled: bool = true
@export var price: int = 100

var _item_textures: Array[Control] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_item_price.text = "$" + str(price)
	
	var childs = get_children()
	
	for node in childs:		#
		if (node.name != "Control"):
			_item_textures.append(node)
			(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if (is_enabled):
		enable_item()
	else:
		disable_item()

func enable_item():
	_item_price.visible = true
	for item_tex in _item_textures:
		item_tex.visible = true
	_button.visible = true
	(texture as AtlasTexture).region.position = Vector2(0, 0)
	
func disable_item():
	_item_price.visible = false
	for item_tex in _item_textures:
		item_tex.visible = false
	_button.visible = false
	(texture as AtlasTexture).region.position = Vector2(40, 0)

func _on_button_pressed() -> void:
	if(gui_controller.can_buy(price)):
		if (is_tier_buyable):
			_buy_tier_sound_player.play()
		else: 	
			_buy_item_sound_player.play()
			
	purchase_request.emit(price)
