@tool
extends TimelineControlItem
class_name RythmicAnimationPlayerControlItem

@export var unique_name:String : 
	set(v):
		unique_name = v

		if not unique_name.is_empty():
			name = v
			unique_name_in_owner = true
		else:
			unique_name_in_owner = false
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
		
func get_target_property_path() -> NodePath:
	var row_header = get_row_header()
	if not row_header:
		return NodePath()
		
	return row_header.get_target_node_property_path()

func begin() -> void:
	pass

func end() -> void:
	pass

func flash() -> void:
	if tween:
		tween.kill()
	
	pivot_offset = size * 0.5
	
	tween = create_tween()
	tween.tween_property(self, "z_index", 1, 0)
	tween.tween_property(self, "scale", Vector2.ONE * 1.5, 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	tween.tween_property(self, "z_index", 0, 0)
	#tween.tween_property(self, "modulate", Color.GREEN, 0.1)
	#tween.tween_property(self, "modulate", Color.WHITE, 0.1)
