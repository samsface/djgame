extends HBoxContainer

signal value_changed

@export var value:String :
	set(v):
		value = v
		$Value.text = v

func _value_changed(value):
	value_changed.emit(value)
