extends MeshInstance3D

func _physics_process(delta: float) -> void:
	global_position.z = floor(get_parent().global_position.z * 100.0) / 100.0
