extends Node3D
class_name Arrow

@onready var mesh = $Cube
@onready var light = $OmniLight3D

var intro_light_tween_:Tween

func _ready() -> void:
	intro_light_tween_ = create_tween()
	intro_light_tween_.tween_property(light, "light_energy", 1, 0.3)

func explode(scale := 1.0) -> Tween:
	if intro_light_tween_:
		intro_light_tween_.kill()
	
	mesh.set_instance_shader_parameter("scale", scale)

	var tween = create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(mesh, "instance_shader_parameters/ttl", 1.0, 0.35)
	tween.tween_property(light, "light_energy", 8.0, 0.1)
	tween.tween_property(light, "light_energy", 0.0, 0.2).set_delay(0.1)

	$SfxrStreamPlayer3D.pitch_scale = randf_range(1.5, 2.0)
	$SfxrStreamPlayer3D.play()

	return tween

func orient(from:Vector3, to:Vector3) -> void:
	var p = global_position
	global_position = to
	look_at(from)
	global_position = p


