extends Node3D

@export var global_gravity := -0.5
@export var air_resistnace := 24.0

var height_map:PackedFloat32Array
var height_map_origin:Vector3
var height_map_width:int

var bodies_ := []

func reset() -> void:
	bodies_.clear()

func push(object) -> void:
	if object is VerletBody:
		bodies_.push_back(object)
		#object.connect("tree_exited", self, "_object_exit_tree", [object])

func _physics_process(delta) -> void:
	for body in bodies_:
		for atom in body.atoms_:
			if atom.dynamic == 0.0:
				continue

			atom.tick(delta)
			atom.position += (Vector3(0.0, body.gravity * global_gravity, 0.0) * delta)
			
			var f = atom.position - atom.last_position
			atom.position -= f * delta * air_resistnace

		if height_map:
			for atom in body.atoms_:
				var ap:Vector3 = atom.global_position - height_map_origin
				ap *= height_map_width
				
				if ap.x >= height_map_width or ap.z >= height_map_width:
					continue
					
				if ap.x < 0.0 or ap.z < 0.0:
					continue

				var iv = ap.floor()
			
				var idx:int = iv.z * height_map_width + iv.x
			
				var f = height_map[idx]

				if atom.global_position.y < f:
					atom.global_position.y = lerp(atom.global_position.y , f, delta * 44.0)
					atom.last_position.y = atom.position.y

		for i in range(10):
			for bond in body.bonds_:
				bond.tick(delta)
