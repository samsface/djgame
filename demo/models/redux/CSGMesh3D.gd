@tool
extends CSGMesh3D



@export var size:Vector3 :
	set(v):
		size = v
		resize()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
			surface[Mesh.ARRAY_VERTEX][i] = surface[Mesh.ARRAY_VERTEX][i] + Vector3.LEFT * size.x
	
	var array_mesh_new := ArrayMesh.new()
	array_mesh_new.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface)
	
	mesh = array_mesh_new
	
