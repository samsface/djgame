@tool
extends Node3D

@export var light:float :
	set(value):
		light = value
		get_child(0).set_instance_shader_parameter("emission_scale", value)

@export var electric:Color = Color.TRANSPARENT :
	set(value):
		electric = value
		get_child(0).set_instance_shader_parameter("electric_albedo", electric)

func _ready() -> void:
	get_child(0).set_instance_shader_parameter("rand", randf())
