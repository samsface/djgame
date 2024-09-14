extends MeshInstance3D
class_name Arrow

@export var albedo : Color :
	set(v):
		albedo = v
		if light:
			light.light_color = albedo
			set_instance_shader_parameter("albedo", albedo)

@export var length : float :
	set(v):
		length = v
		$MeshInstance3D.set_instance_shader_parameter("tail_length2", length)

@export var freq : float :
	set(v):
		freq = v
		$MeshInstance3D.set_instance_shader_parameter("freq", freq)
		
@export var amp : float :
	set(v):
		amp = v
		$MeshInstance3D.set_instance_shader_parameter("amp", amp)
		
		
@onready var light = $OmniLight3D

var intro_light_tween_:Tween

func _ready() -> void:
	albedo = albedo

	intro_light_tween_ = create_tween()
	intro_light_tween_.tween_property(light, "light_energy", 1, 0.3)

func explode(scale := 1.0) -> Tween:
	if intro_light_tween_:
		intro_light_tween_.kill()
	
	set_instance_shader_parameter("scale", scale)

	var tween = create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "instance_shader_parameters/ttl", 1.0, 0.35).from(0.2)
	tween.tween_property(light, "light_energy", 8.0, 0.1)
	tween.tween_property(light, "light_energy", 0.0, 0.2).set_delay(0.1)

	$AudioStreamPlayer3D.pitch_scale = randf_range(1.5, 2.0)
	$AudioStreamPlayer3D.play()

	return tween

func orient(from:Vector3, to:Vector3) -> void:
	var p = global_position
	global_position = to
	look_at(from)
	global_position = p
