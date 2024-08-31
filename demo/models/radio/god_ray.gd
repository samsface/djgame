@tool
extends MeshInstance3D

@export_range(0.0, 1.0) var intensity := 0.0 :
	set(v):
		intensity = v
		material_override.set_shader_parameter("a", intensity)

func _process(delta: float) -> void:
	rotate_y(delta * 0.2)
