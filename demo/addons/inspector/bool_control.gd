extends HBoxContainer

signal value_changed

@export var value:bool :
	set(v):
		value = v
		$Value.button_pressed = v

func _value_toggled(value):
	value_changed.emit(value)
