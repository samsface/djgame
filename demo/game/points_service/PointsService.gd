extends Node3D

signal points_changed

var damage_tween_:Tween

@export var points:int :
	set(value):
		points = value
		points_changed.emit(points)
		%Score.set_points(points)

var combo := 0
var no_touch_:Node3D

func _ready() -> void:
	$CanvasLayer/ColorRect.material.set_shader_parameter("damage", 0.0)

func miss() -> void:
	if damage_tween_:
		damage_tween_.kill()

	damage_tween_ = create_tween()
	damage_tween_.tween_property($CanvasLayer/ColorRect.material, "shader_parameter/damage", 1.0, 0.05)
	damage_tween_.tween_property($CanvasLayer/ColorRect.material, "shader_parameter/damage", 0.0, 0.2)

func make_points():
	var points = preload("res://game/points_service/points.tscn").instantiate()
	add_child(points)
	return points

func no_touch(node:Node3D) -> void:
	if no_touch_ == node:
		return

	no_touch_ = node

	var points = make_points()
	points.position = node.global_position
	points.no_touch()
	points.commit()
	
	var tween := create_tween()
	tween.tween_interval(1.0)
	tween.finished.connect(func(): 
		points.queue_free(); 
		if no_touch_ == node:
			no_touch_ = null
	)
