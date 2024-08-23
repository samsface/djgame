@tool
extends EditorScenePostImport

func _post_import(scene):
	if scene.get_child_count() == 0:
		return

	for child in scene.get_children():
		if child.name.ends_with("-path"):
			var res := mesh_instance_to_path(child)
			if res:
				scene.add_child(res)
				res.owner = scene
				scene.remove_child(child)
				res.name = child.name

	return scene

func mesh_instance_to_path(mesh_instance:MeshInstance3D) -> Path3D:
	if not mesh_instance:
		return

	var mesh:Mesh = mesh_instance.mesh
	if not mesh:
		return

	var arrays := mesh.surface_get_arrays(0)
	if not arrays:
		return
		
	var path := Path3D.new()
	path.curve = Curve3D.new()

	var indexes = arrays[Mesh.ARRAY_INDEX]
	var verts = arrays[Mesh.ARRAY_VERTEX]
	
	var l
	
	for i in indexes.size():
		var c = verts[indexes[i]]
		if c == l:
			continue
		path.curve.add_point(verts[indexes[i]])
		l = c

	return path
