extends Node3D

@onready var body_ = $CSGSphere3D

func _ready() -> void:
	Camera.recorder.play.connect(dance_1)
	$CSGSphere3D.material.set_shader_parameter("albedo", HyperRandom.fruity_color())
	

func rand_vec() -> Vector3:
	return Vector3(
		randf_range(-1, 1),
		randf_range(-1, 1),
		randf_range(-1, 1)
	)

func dance_1() -> void:
	var tween := create_tween()
	tween.set_speed_scale(4.0 + randf_range(-0.1, 0.1))
	tween.set_trans(Tween.TRANS_CIRC)
	
	tween.set_parallel()
	tween.tween_property(body_, ^"rotation", rand_vec() * 0.5, 1.0)
	tween.tween_property(body_, ^"position:y", 0.1, 1.0)

	tween.set_parallel(false)
	tween.tween_property(body_, ^"rotation", Vector3.ZERO, 1.0)
	tween.tween_property(body_, ^"position:y", 0.0, 1.0)

	tween.finished.connect(dance_1)
