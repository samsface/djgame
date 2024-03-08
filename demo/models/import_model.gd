@tool
extends EditorScenePostImport

class Triangle:
	var vertex1: Vector3
	var vertex2: Vector3
	var vertex3: Vector3
	var normal: Vector3
	var uv1: Vector2
	
	func _init(vertex1: Vector3, vertex2: Vector3, vertex3: Vector3) -> void:
		self.vertex1 = vertex1
		self.vertex2 = vertex2
		self.vertex3 = vertex3
	
	func get_random_point() -> Vector3:
		# Generate random barycentric coordinates
		var u = randf()
		var v = randf() * (1.0 - u)
		var w = 1.0 - u - v

		# Ensure that u + v + w = 1
		var total = u + v + w
		u /= total
		v /= total
		w /= total

		# Calculate the random point on the triangle's surface
		var random_point = vertex1 * u + vertex2 * v + vertex3 * w
		
		return random_point

	func get_center_point() -> Vector3:
		var center_x = (vertex1.x + vertex2.x + vertex3.x) / 3.0
		var center_y = (vertex1.y + vertex2.y + vertex3.y) / 3.0
		var center_z = (vertex1.z + vertex2.z + vertex3.z) / 3.0
		return Vector3(center_x, center_y, center_z)

	func get_area() -> float:
		# Calculate two vectors representing the sides of the triangle
		var side1 = vertex2 - vertex1
		var side2 = vertex3 - vertex1

		# Calculate the cross product of the two sides
		var cross_product = side1.cross(side2)

		# Calculate the magnitude of the cross product, which is half of the triangle's area
		var area = cross_product.length() / 2.0

		return area
	
	func is_vertical() -> bool:
		
		# Calculate the normal vector of the triangle
		var edge1 = vertex2 - vertex1
		var edge2 = vertex3 - vertex1
		var normal = edge1.cross(edge2).normalized()
		
		# Calculate the angle between the normal vector and the vertical axis
		var vertical_axis = Vector3(0, 1, 0)  # Assuming Y-axis is vertical
		var dot_product = normal.dot(vertical_axis)
		var angle = acos(dot_product)
		
		# You can adjust the threshold angle (in radians) to define what you consider "more or less vertical"
		var threshold_angle = deg_to_rad(45)  # Adjust this value as needed
		
		return abs(angle - PI/2.0) < threshold_angle
		
	func get_normal() -> Vector3:
		# Calculate the normal vector of the triangle
		var edge1 = vertex2 - vertex1
		var edge2 = vertex3 - vertex1
		var normal = edge1.cross(edge2).normalized()
		return normal

	static func array_mesh_to_triangles(array_mesh:ArrayMesh):
		var res := []

		if not array_mesh:
			return res

		var faces = array_mesh.surface_get_arrays(0)[PrimitiveMesh.ARRAY_VERTEX]
		var normals = array_mesh.surface_get_arrays(0)[PrimitiveMesh.ARRAY_NORMAL]
		var colors = array_mesh.surface_get_arrays(0)[PrimitiveMesh.ARRAY_TEX_UV]

		for i in faces.size() / 3:
			var triangle := Triangle.new(faces[i * 3 + 0], faces[i * 3 + 1], faces[i * 3 + 2])
			triangle.normal = normals[i * 3 + 0]
			triangle.uv1 = colors[i * 3 + 0]
			res.push_back(triangle)

		return res

func iterate(root, node, node_names):
	var bank := {
		255: load("res://models/toydrum/button.tscn"),
		250: load("res://models/toydrum/button2.tscn"),
		243: load("res://models/lital/slider.tscn")
	}

	if node != null:
		if node.name.contains("Widget"):
			if node is MeshInstance3D:
				var triangles = Triangle.array_mesh_to_triangles(node.mesh)

				for tri in triangles:
					var widget = bank.get(int(tri.uv1.x * 255))
					if not widget:
						continue

					var ii = widget.instantiate()
					ii.position = tri.get_center_point()
					ii.rotate_x(-tri.normal.z)
					
					if not node_names.is_empty():
						ii.name = node_names.pop_front()

					root.add_child(ii)
					ii.owner = root

		for child in node.get_children():
			iterate(root, child, node_names)

func _post_import(scene:Node) -> Object:
	var path := get_source_file().get_base_dir().path_join("node_names.txt")
	var node_names
	if FileAccess.file_exists(path):
		print("Found node name file")
		var file := FileAccess.open(path, FileAccess.READ) 
		if file:
			node_names = Array(file.get_as_text(true).split("\n"))

	iterate(scene, scene, node_names)
	return scene
