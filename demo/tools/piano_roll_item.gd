extends Button
class_name PianoRollItem

signal changed

@export var piano_roll_:Node

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

func end(db, node) -> void:
	pass
