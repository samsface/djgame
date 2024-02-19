extends Node3D

func make_text() -> Node3D:
	var hit := preload("res://models/guide/hit.tscn").instantiate()
	add_child(hit)
	return hit

func make_pts_text(points:int, pos:Vector3) -> void:
	var text = make_text()
	text.text = "%d PTS" % points
	text.ok()
	text.global_position = pos
	text.hang_time = 0.25

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
