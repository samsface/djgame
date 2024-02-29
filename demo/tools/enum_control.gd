extends HBoxContainer

signal value_changed

@export var value:int :
	set(v):
		value = v
		$Value.select(v)

func _item_selected(index):
	value_changed.emit(index)
