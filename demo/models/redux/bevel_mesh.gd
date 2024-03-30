@tool
extends CSGMesh3D

@export var size:Vector3 :
	set(value):
		size = value
		make_cube(size.x, size.y, size.z, 5)

func make_cube(width, height, length, bevel_radius) -> void:
	var vertices = PackedVector3Array()
	
	
	vertices.push_back(Vector3(0, 0, 0))
	vertices.push_back(Vector3(width, 0, 0))
	vertices.push_back(Vector3(width, 0, height))
	
	var indicies = [0, 1, 2]
	
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for v in vertices:
		st.set_uv(Vector2.ZERO)
		st.add_vertex(v)
		
	for i in indicies:
		st.add_index(i)
		
	st.generate_normals()
	st.generate_tangents()
	
	var am = st.commit()

	mesh = am
