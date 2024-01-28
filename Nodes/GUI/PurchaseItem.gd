extends Node

@onready var _texture: TextureRect = $MainContainer
@onready var _buyable_item_texture: TextureRect = $BuyableItem
@onready var _item_price: RichTextLabel = $ItemPrice

@export var is_enabled: bool = false
@export var price: int = 100
@export var item_texture = _buyable_item_texture

# Called when the node enters the scene tree for the first time.
func _ready():
	_item_price.text = "$" + str(price)
	
	if (is_enabled):
		enable_item()
	else:
		disable_item()

func enable_item():
	_item_price.visible = true
	_buyable_item_texture.visible = true
	_texture.position.x = 0
	
func disable_item():
	_item_price.visible = false
	_buyable_item_texture.visible = false	
	_texture.position.x = 40

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
