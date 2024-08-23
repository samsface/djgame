@tool
extends Node3D

@export var light:float :
	set(v):
		light = v
		get_child(0).set_instance_shader_parameter("emission_scale", v)

@export var electric:Color = Color.TRANSPARENT :
	set(v):
		electric = v
		get_child(0).set_instance_shader_parameter("electric_albedo", electric)

@export var albedo:Color :
	set(v):
		albedo = v
		get_child(0).set_instance_shader_parameter("albedo", albedo)

@export_range(0.0, 1.0) var wear:float :
	set(v):
		wear = v
		get_child(0).set_instance_shader_parameter("wear", wear)

@export var wear_albedo:Color :
	set(v):
		wear_albedo = v
		get_child(0).set_instance_shader_parameter("wear_albedo", wear_albedo)

func _ready() -> void:
	get_child(0).set_instance_shader_parameter("rand", randf())
