extends CSGMesh3D

@export var path:Path3D
@export var grasses := {}
@export var invalidate:bool :
	set(v):
		invalidate = false
		generate_grass()

func _ready() -> void:
	for grass in grasses:
		var p := preload("res://models/road/grass.tscn").instantiate()
		p.position = grass
		p.multimesh.buffer = grasses[grass]
		add_child(p)

func random_point_in_triangle(p1: Vector3, p2: Vector3, p3: Vector3) -> Vector3:
	# Generate two random numbers between 0 and 1
	var r1 = randf()
	var r2 = randf()

	# Adjust the random numbers to ensure the point is inside the triangle
	if r1 + r2 > 1:
		r1 = 1 - r1
		r2 = 1 - r2

	# Calculate the random point usinggrass barycentric coordinates
	var point = (1 - r1 - r2) * p1 + r1 * p2 + r2 * p3

	return point

func generate_grass() -> void:
	grasses.clear()
	
	var arrays := mesh.surface_get_arrays(0)
	var indexes = arrays[Mesh.ARRAY_INDEX]
	var vertexes = arrays[Mesh.ARRAY_VERTEX]

	for i in range(0, indexes.size(), 3):
		var grass := PackedFloat32Array()
		
		var center_point:Vector3 = (vertexes[indexes[i]] + vertexes[indexes[i + 1]] + vertexes[indexes[i + 2]]) / 3.0
		
		for j in 100:
			var random_point := random_point_in_triangle(vertexes[indexes[i]], vertexes[indexes[i + 1]], vertexes[indexes[i + 2]])
			random_point -= center_point
			add_(grass, random_point)

		grasses[center_point] = grass

func add_(data:PackedFloat32Array, position:Vector3):
		#position.y -= randf() * 0.2
		var t := Transform3D()
		t = t.rotated(Vector3.UP, randf() * PI)
		t = t.translated(position)

		var offset := data.size()

		data.resize(data.size() + 12)

		data[offset + 0] = t.basis[0].x
		data[offset + 1] = t.basis[0].y
		data[offset + 2] = t.basis[0].z
		data[offset + 3] = t.origin.x
		
		data[offset + 4] = t.basis[1].x
		data[offset + 5] = t.basis[1].y
		data[offset + 6] = t.basis[1].z
		data[offset + 7] = t.origin.y
		
		data[offset + 8] = t.basis[2].x
		data[offset + 9] = t.basis[2].y
		data[offset + 10] = t.basis[2].z
		data[offset + 11] = t.origin.z
