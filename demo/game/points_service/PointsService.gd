extends Node3D
class_name PointsService

var stats_ := {}
var l := Vector3.ZERO
var energy := 0.0
var depth := 6.0

@onready var good_boy = %GoodBoy
@onready var label = %Label3D

func center(meter, offset:Vector2 = Vector2.ZERO):
	meter.position = %Camera3D.project_position(Bus.bars.get_rect().get_center() + offset, depth)

func get_center(offset:Vector2 = Vector2.ZERO) -> Vector3:
	return %Camera3D.project_position(Bus.bars.get_rect().get_center() + offset, depth)

func _ready() -> void:
	Bus.audio_service.open_patch("res://junk/radio.pd")
	
	Bus.points_service = self
	stats_["hp"]= %HP
	stats_["good_boy"] = %Goodboy
	
	await  get_tree().process_frame

	%Camera3D.environment = Bus.env.environment

func _physics_process(delta: float) -> void:
	#$CanvasLayer/MarginContainer2.position = Bus.bars.get_rect().position
	#$CanvasLayer/MarginContainer2.size = Bus.bars.get_rect().size

	%DoctorIcon.get_child(0).rotate_y(delta)
	
	var new_l = Bus.camera_service.camera_.global_rotation
	var d = new_l.distance_to(l) * 10.0
	energy = lerp(energy, energy + d, delta)

	%GoodBoy/Mesh.mesh.material.next_pass.set_shader_parameter("energy", energy)
	
	l = new_l
	
	energy = lerp(energy, 0.0, delta)
	
	# it doesn't look good to match the env light exactly, player just needs to feel a little interaction
	# while keeping the liquid wavey line clear
	$CanvasLayer2/SubViewportContainer/SubViewport/DirectionalLight3D.rotation.x = deg_to_rad(-54) - Bus.camera_service.camera_.global_rotation.x * 0.5
	#$SubViewportContainer/SubViewport/DirectionalLight3D.global_rotation.y = 0# Bus.camera_service.camera_.global_rotation.y * 0.5
	
	sort_meters_(delta)
	

func sort_meters_(delta:float) -> void:
	var top_left = %Camera3D.project_position(Bus.bars.get_rect().position, 0.5)
	
	for meter in %Meters.get_children():
		if meter.sort:
			var position2 = %Camera3D.unproject_position(meter.get_node("Pivot").global_position)
			var position3 = Bus.bars.get_rect().position + Vector2(32, 16)
			var l = lerp(position2, position3, delta * 5.0)
			var k = %Camera3D.project_position(l, depth)

			meter.position = k - meter.get_node("Pivot").position

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
	stats_[stat].get_parent().visible = value

	if value:
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(stats_[stat], "global_position:y", stats_[stat].global_position.y, 2.3)
		stats_[stat].global_position.y = $CanvasLayer/MarginContainer2.global_position.y + $CanvasLayer/MarginContainer2.size.y

func set_points(stat:String, points:float) -> void:
	stats_[stat].points = points

func get_points(stat:String):
	return stats_[stat].points

func add_points(stat:String, points:float) -> void:
	stats_[stat].add_points(points)
