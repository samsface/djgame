@tool
extends Button
class_name TimelineControlItem

signal changed

@export var piano_roll_:Node

@export var disable_resize:bool

@export var time:int :
	set(v):
		time = v
		if piano_roll_:
			position.x = piano_roll_.to_local(time)
			changed.emit()

@export var length:int :
	set(v):
		length = v
		if piano_roll_:
			size.x = piano_roll_.to_local(length)
			changed.emit()

func get_row_header() -> Control:
	if piano_roll_ and get_parent():
		return piano_roll_.get_row_header(get_parent().get_index())
	else:
		return null
