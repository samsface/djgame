extends CSGMesh3D

var bones_ = PackedVector3Array()

func set_bone_pose_position(bone_idx:int, position:Vector3) -> void:
	bones_[bones_.size() - 1 - bone_idx] = position
	
func _physics_process(delta: float) -> void:
	material.set_shader_parameter("bones", bones_)
