extends Node3D

signal points_changed
signal zero

var damage_tween_:Tween
var decay := 0.0

@onready var hp_ = $CanvasLayer/MarginContainer2/HP

var hp := 0.5 : 
	set(v):
		if v == hp_.value_:
			return

		if hp_.value_ > v:
			miss()

		hp_.set_points(v)
	get:
		return hp_.value

var combo := 0
var no_touch_:Node3D

func _ready() -> void:
	hp_.zero.connect(_zero)
	$CanvasLayer/ColorRect.material.set_shader_parameter("damage", 0.0)

func _zero() -> void:
	$CanvasLayer/Dead.visible = true
	Camera.audio_service.stop()

func _physics_process(delta:float) -> void:
	hp_.decay(decay * delta)

func play() -> void:
	decay = 0.025

func miss() -> void:
	$RecordScratch.play()
	
	if damage_tween_:
		damage_tween_.kill()

	damage_tween_ = create_tween()
	damage_tween_.tween_property($CanvasLayer/ColorRect.material, "shader_parameter/damage", 1.0, 0.05)
	damage_tween_.tween_property($CanvasLayer/ColorRect.material, "shader_parameter/damage", 0.0, 1.0)

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

func win():
	$CanvasLayer/Win.visible = true
	Camera.audio_service.stop()
