extends Node3D

@export var light:float :
	set(value):
		get_child(0).set_instance_shader_parameter("light", value)
