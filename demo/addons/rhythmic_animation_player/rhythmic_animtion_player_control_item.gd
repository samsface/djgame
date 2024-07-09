@tool
extends TimelineControlItem
class_name RythmicAnimationPlayerControlItem

var active := false
var db = Object.new()
var tween:Tween

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

func flash() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "modulate", Color.GREEN, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
