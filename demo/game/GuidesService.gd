extends Node3D
class_name GuideService

func slide(nob:Node3D, length:float, from_value:float, to_value:float):
	var pos = nob.get_guide_position_for_value(from_value)
	var d = preload("res://game/guide/slide/slide.tscn").instantiate()
	d.points_service = $"../PointsService"
	d.position = pos
	d.watch(nob, from_value, to_value, length)

	add_child(d)

func bang(nob:Node3D, length:float, value:float, auto:bool):
	var pos = nob.get_guide_position_for_value(value)
	var d = preload("res://game/guide/bang/bang.tscn").instantiate()
	d.auto = auto
	d.points_service = $"../PointsService"
	d.position = pos
	d.length = length
	d.watch(nob, value)
	nob.intended_value = value

	add_child(d)
