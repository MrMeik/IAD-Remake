extends TextureRect

class_name MoneyDisplay

@onready var _text_label = $RichTextLabel
@onready var _base_texture = load("res://Sprites/GUI/Money_Display.png")
@onready var _flash_texture = load("res://Sprites/GUI/Money_Display_Glow.png")
@onready var _timer = $FlashTimer

var _remaining_flash_count = 4

var _last_value: int = 1000

func update_display(value: int) -> void:
	_last_value = value
	_text_label.text = str(value)
	
func flash_display():
	_remaining_flash_count = 4
	_timer.start()
	texture = _flash_texture

func _on_flash_timer_timeout():
	_remaining_flash_count = _remaining_flash_count - 1
	if (_remaining_flash_count > 0):
		if (_remaining_flash_count % 2 == 0):
			texture = _base_texture
		else:
			texture = _flash_texture
		_timer.start()
	else:
		texture = _base_texture
