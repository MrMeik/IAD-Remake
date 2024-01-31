extends TextureRect

class_name MoneyDisplay

@onready var _text_label = $RichTextLabel

var _last_value: int = 1000

func update_display(value: int) -> void:
	_last_value = value
	_text_label.text = str(value)
