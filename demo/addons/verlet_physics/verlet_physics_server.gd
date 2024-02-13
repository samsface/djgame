extends Node3D

@export var global_gravity := -0.01
@export var air_resistnace := 1.0

var bodies_ := []

func reset() -> void:
	bodies_.clear()

func push(object) -> void:
	if object is VerletBody:
		bodies_.push_back(object)
		#object.connect("tree_exited", self, "_object_exit_tree", [object])

func _process(delta) -> void:
	for body in bodies_:
		for atom in body.atoms_:
			if atom.dynamic == 0.0:
				continue

			atom.tick(delta)
			atom.position += (Vector3(0.0, body.gravity * global_gravity, 0.0) * delta)
			
			#var f = atom.position - atom.last_position
			#atom.position -= f * delta * air_resistnace

		for i in range(4):
			for bond in body.bonds_:
				bond.tick(delta)
