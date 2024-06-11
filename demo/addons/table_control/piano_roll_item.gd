extends Button
class_name PianoRollItem

signal changed

@export var piano_roll_:Node

@export var disable_resize:bool

@export var time:int :
	set(v):
		time = v
		if piano_roll_:
			position.x = piano_roll_.to_local(time)

@export var length:int :
	set(v):
		length = v
		if piano_roll_:
			size.x = piano_roll_.to_local(length)

var active := false

func get_lookahead() -> int:
	return 0

func fill() -> bool:
	return false

func get_target_node():
	if not get_parent():
		return null

	return get_parent().target_node

func op(db, node, length) -> void:
	pass

func end() -> void:
	pass

func get_time() -> int:
	return position.x / piano_roll_.grid_size
