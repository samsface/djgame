extends Control

signal value_changed

@export var value:String :
	set(v):
		value = v
		$Value.text = v

func _value_changed(value):
	value_changed.emit(value)

func _value_changed_alt():
	value_changed.emit($Value.text)
