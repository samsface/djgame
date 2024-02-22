extends VerletBody

@export var bone_count := 16

var data_ := PackedVector3Array()

func _ready() -> void:
	var last_atom:VerletAtom

	for i in bone_count:
		var a = VerletAtom.new()
		a.position = Vector3.UP * (1.0 / float(bone_count) ) * i
		add_child(a)
		
		if last_atom:
			var bond := VerletBond.new()
			bond.atom_a = last_atom.get_path()
			bond.atom_b = a.get_path()
			add_child(bond)

		last_atom = a

	data_.resize(bone_count)

	mesh.rings = bone_count - 2
	invalidate_()
	
	atoms_[0].dynamic = 0.0

func _physics_process(delta: float) -> void:
	for i in atoms_.size():
		data_[i] = atoms_[i].position
		
	mesh.material.set_shader_parameter("bones", data_)
