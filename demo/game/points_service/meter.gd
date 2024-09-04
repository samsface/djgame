extends Node3D

@export_range(0.0, 1.0) var value := 0.0 :
	set(v):
		if v < value:
			danger_()
			$Mesh.mesh.material.next_pass.set_shader_parameter("fill", v)
		else:
			ok_()
			$Mesh.mesh.material.next_pass.set_shader_parameter("fill", v)
		
		value = v

@export var color := Color.AQUA
@export var color_surface := Color.AQUA
@export var color_danger := Color.AQUA

@export var sort:bool

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
	$Mesh.mesh.material.next_pass.set_shader_parameter("albedo", color)
	$Mesh.mesh.material.next_pass.set_shader_parameter("albedo_surface", lerp(color_surface, color_danger, danger_cooldown_))
	
	danger_cooldown_ = max(danger_cooldown_ - delta, 0)
