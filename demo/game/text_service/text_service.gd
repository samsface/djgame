extends Node3D

var owners_ := {}

func make_text(parent:Node3D = null) -> Node3D:
	if owners_.has(parent):
		return owners_[parent]
	
	var hit := preload("res://game/text_service/text.tscn").instantiate()
	add_child(hit)
	
	owners_[parent] = parent

	return hit

func make_pts_text(points:int, pos:Vector3):
	var text = make_text()
	text.text = "%d PTS" % points
	text.ok()
	text.global_position = pos
	text.hang_time = 0.25
	return text
	
func make_too_high_text(pos:Vector3) -> void:
	var text = make_text()
	text.text = "TOO HIGH!"
	text.danger()
	text.global_position = pos
	text.hang_time = 0.25

func make_too_low_text(pos:Vector3) -> void:
	var text = make_text()
	text.text = "TOO LOW!"
	text.danger()
	text.global_position = pos
	text.hang_time = 0.25
	
func make_lost_combo(pos:Vector3, combo:int) -> void:
	var text = make_text()
	text.text = "x %d COMBO LOST" % combo
	text.danger()
	text.global_position = pos
	text.hang_time = 0.5
