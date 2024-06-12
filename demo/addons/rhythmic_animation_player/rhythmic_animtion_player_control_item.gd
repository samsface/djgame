@tool
extends TimelineControlItem
class_name RythmicAnimationPlayerControlItem

var active := false

func get_lookahead() -> int:
	return 0

func fill() -> bool:
	return false

func get_target_node():
	var row_header = get_row_header()
	if not row_header:
		return null
	
	return row_header.try_get_node()
		
func begin() -> void:
	pass

func end() -> void:
	pass
