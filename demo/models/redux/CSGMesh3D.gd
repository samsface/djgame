@tool
extends Node3D

@export var size:Vector3 :
	set(v):
		size = v
		resize()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func center_verts_on_origin(vertices:PackedVector3Array) -> Vector3:
	# Initialize min and max vectors
	var min_vertex = Vector3.ONE * 999999
	var max_vertex = Vector3.ONE * -999999

	# Find the minimum and maximum values for each dimension
	for vertex in vertices:
		min_vertex.x = min(min_vertex.x, vertex.x)
		min_vertex.y = min(min_vertex.y, vertex.y)
		min_vertex.z = min(min_vertex.z, vertex.z)

		max_vertex.x = max(max_vertex.x, vertex.x)
		max_vertex.y = max(max_vertex.y, vertex.y)
		max_vertex.z = max(max_vertex.z, vertex.z)

	# Calculate the center point
	var center = (min_vertex + max_vertex) / 2.0

	# Calculate the offset vector to center the vertices around the origin
	var offset = -center

	return offset

func resize():
	var om := load("res://models/lital/bevel_box.obj")

	var surface:Array = om.surface_get_arrays(0)

	for i in surface[Mesh.ARRAY_VERTEX].size():
		var color:Color = surface[Mesh.ARRAY_COLOR][i]
		if color.r > 0.0:
			surface[Mesh.ARRAY_VERTEX][i] = surface[Mesh.ARRAY_VERTEX][i] + Vector3.UP * size.y
		if color.g > 0.0:
			surface[Mesh.ARRAY_VERTEX][i] = surface[Mesh.ARRAY_VERTEX][i] + Vector3.FORWARD * size.z
		if color.b > 0.0:
			surface[Mesh.ARRAY_VERTEX][i] = surface[Mesh.ARRAY_VERTEX][i] + -Vector3.LEFT * size.x

	var center_offset := center_verts_on_origin(surface[Mesh.ARRAY_VERTEX])

	for i in surface[Mesh.ARRAY_VERTEX].size():
		surface[Mesh.ARRAY_VERTEX][i] += center_offset

	var array_mesh_new := ArrayMesh.new()
	array_mesh_new.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface)
	
	set("mesh", array_mesh_new)
	
