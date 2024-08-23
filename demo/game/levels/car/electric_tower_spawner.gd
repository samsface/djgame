extends Node3D

@export var path:Node3D
@export var delay:int

var x_ := {}

func spawn(time, length) -> void:
	time += delay
	
	if x_.has(time):
		return
	
	x_[time] = true

	var curve:Curve3D = path.curve
	var p = curve.sample_baked((time / 960.0) * curve.get_baked_length())

	var a = preload("res://models/road/tower.glb").instantiate()
	a.rotate_y(PI * 0.5)
	a.position = p
	a.position.z = 10
	add_child(a)
