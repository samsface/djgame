extends Node3D

@export var path:Node3D
@export var delay:int
@export var prop:PackedScene
@export var h_offset:float

var x_ := {}
var last_

func spawn(time, length) -> void:
	time += delay
	
	if x_.has(time):
		return
	
	x_[time] = true

	var curve:Curve3D = path.curve
	var p = curve.sample_baked((time / 480.0) * curve.get_baked_length())

	var a = prop.instantiate()
	a.rotate_y(PI * 0.5)
	a.position = p
	a.position.z = h_offset
	add_child(a)

	if last_:
		link(last_, a)

	last_ = a

func link(last, new) -> void:
	if "cables_out" not in last:
		return

	for i in last.cables_out.size():
		var cable := preload("res://models/road/cable.tscn").instantiate()
		add_child(cable)

		cable.link(last.cables_out[i].global_position, new.cables_in[i].global_position)
