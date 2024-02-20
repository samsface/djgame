extends Node3D

@export var light:float :
	set(value):
		get_child(0).set_instance_shader_parameter("emission_scale", value)
		
@export var outline:Color :
	set(value):
		get_child(0).set_instance_shader_parameter("outline_color", value)

func _ready() -> void:
	get_child(0).set_instance_shader_parameter("rand", randf())
