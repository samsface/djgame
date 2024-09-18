extends Node3D

var value_ := 0.0
var displayed_value_ := 0.0

@export_range(0.0, 1.0) var value := 0.0 :
	set(v):
		v = clamp(v, 0.0, 1.0)
		
		if v < value_:
			danger_()
		else:
			ok_()

		value_ = v
	get:
		return value_

@export var color := Color.AQUA
@export var color_surface := Color.AQUA
@export var color_danger := Color.AQUA

@export var sort:bool

@export var unit:String

var combo := 0

var danger_cooldown_ := 0.0

func ok_() -> void:
	pass

func danger_() -> void:
	if not is_visible_in_tree():
		return

	if danger_cooldown_ > 0.75:
		return

	danger_cooldown_ = 1.0
	
	var tween := create_tween()
	for i in 5:
		tween.tween_property(self, "position", position + HyperRandom.random_vector3() * 0.01, 0.08)

func _physics_process(delta: float) -> void:
	value_ = 0.5
	if value_ > 0.0:
		value_ += delta * 0.02
		value_ = clamp(value_, 0, 1)
	
	
	displayed_value_ = lerp(displayed_value_, value_, delta * 10.0)
	$Mesh.mesh.material.next_pass.set_shader_parameter("fill", displayed_value_)
	
	$Mesh.mesh.material.next_pass.set_shader_parameter("albedo", color)
	$Mesh.mesh.material.next_pass.set_shader_parameter("albedo_surface", lerp(color_surface, color_danger, danger_cooldown_))
	
	danger_cooldown_ = max(danger_cooldown_ - delta, 0)
