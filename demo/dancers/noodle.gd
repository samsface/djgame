extends CSGMesh3D

var bones_ = PackedVector3Array()

func _ready() -> void:
	bones_.resize(3)

func set_bone_position(bone_idx:int, position:Vector3) -> void:
	bones_[2 - bone_idx] = position * 2.0
	
func _physics_process(delta: float) -> void:
	material.set_shader_parameter("bones", bones_)
