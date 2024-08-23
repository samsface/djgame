extends MultiMeshInstance3D

func _physics_process(delta: float) -> void:
	var camera_position := get_viewport().get_camera_3d().global_position
	var distance_to_camera = camera_position.distance_to(self.global_position)
	
	#multimesh.visible_instance_count = d

func invalidate_() -> void:
	pass
