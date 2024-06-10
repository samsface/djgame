extends Node3D
class_name GuideService

var active_dilema_groups_ := {}
var slides_ := {}
var bangs_ := {}

func _ready() -> void:
	Bus.guide_service = self

func slide(nob:Node3D, length:float, from_value:float, to_value:float, gluide:float):
	var guide = preload("res://game/guide/slide/slide.tscn").instantiate()
	guide.points_service = $"../PointsService"
	add_child(guide)

	guide.watch(nob, from_value, to_value, length, gluide, false)
	slides_[nob] = guide

func bang(nob:Node3D, time, time_in_seconds:float, value:float, auto:bool, dilema_group:int, silent:bool):
	var pos = nob.get_guide_position_for_value(value)
	var d = preload("res://game/guide/bang/bang.tscn").instantiate()
	d.auto = auto
	d.points_service = $"../PointsService"
	d.position = pos
	d.time = time
	d.length = time_in_seconds
	d.visible = not silent
	d.dilema_group = dilema_group
	d.watch(nob, value)
	nob.intended_value = value

	try_add_to_dilema_group(d, dilema_group)

	add_child(d)
	
	if not bangs_.has(nob):
		bangs_[nob] = []
	bangs_[nob].push_back(d)
	
	if bangs_[nob].size() == 1:
		d.active = true

	d.done.connect(func():
		assert(bangs_[nob].front() == d)
		bangs_[nob].pop_front()
		if not bangs_[nob].is_empty():
			bangs_[nob].front().set_deferred("active", true)
	)
	
func try_add_to_dilema_group(guide:Guide, dilema_group:int):
	if dilema_group > 0:
		var group = active_dilema_groups_.get(dilema_group)
		if group == null:
			group = []
			active_dilema_groups_[dilema_group] = group

		guide.hit.connect(func():
			for g in group:
				if g != guide and is_instance_valid(g):
					g._miss()
			active_dilema_groups_.erase(dilema_group)
			)

		group.push_back(guide)

func nob_has_guide(nob:Nob) -> bool:
	for node in get_children():
		if node.get_nob() == nob:
			return true

	return false
