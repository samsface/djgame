extends HBoxContainer

signal value_changed

@export var value:int :
	set(v):
		value = v
		$Value.value = v
		print(v)

func _value_changed(value):
	value_changed.emit(value)
