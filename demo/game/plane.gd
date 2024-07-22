extends MeshInstance3D

func _process(delta: float) -> void:
	position.z -= delta
