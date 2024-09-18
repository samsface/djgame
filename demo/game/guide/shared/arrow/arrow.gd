extends MeshInstance3D
class_name Arrow

@export var albedo : Color :
	set(v):
		albedo = v
		set_instance_shader_parameter("albedo", albedo)

@export var length : float :
	set(v):
		length = v
		set_instance_shader_parameter("tail_length", length)

@export var freq : float :
	set(v):
		freq = v
		set_instance_shader_parameter("freq", freq)
		
@export var amp : float :
	set(v):
		amp = v
		set_instance_shader_parameter("amp", amp)

@export var spin : float :
	set(v):
		spin = v
		set_instance_shader_parameter("spin", spin)

func _ready() -> void:
	amp = 0
	freq = 0
	length = 0
