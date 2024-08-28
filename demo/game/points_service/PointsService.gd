extends Node3D
class_name PointsService

var stats_ := {}

func _ready() -> void:
	Bus.points_service = self
	stats_["hp"]= $CanvasLayer/MarginContainer2/VBoxContainer/HP
	stats_["good_boy"] = $CanvasLayer/MarginContainer2/VBoxContainer/Goodboy

func play() -> void:
	stats_.hp.decay_rate = 0.01

func make_points(stat:String):
	var points = preload("res://game/points_service/points.tscn").instantiate()
	points.bar = stats_[stat]
	add_child(points)
	return points

func build_points(stat:String, value:int, pos:Vector3, delay:float) -> void:
	if delay:
		await get_tree().create_timer(delay).timeout

	var p = make_points(stat)
	p.position = pos
	p.points = value
	p.commit()
	get_tree().create_timer(0.8).timeout.connect(p.queue_free)

func show_bar(stat:String, value:bool) -> void:
	stats_[stat].visible = value

func set_points(stat:String, points:float) -> void:
	stats_[stat].points = points

func get_points(stat:String):
	return stats_[stat].points

func add_points(stat:String, points:float) -> void:
	stats_[stat].add_points(points)
