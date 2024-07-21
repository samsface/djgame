extends Object
class_name GltfParse

static func load_glb(path: String) -> Mesh:
	var file = FileAccess.open(path, FileAccess.READ)
	var file_len = file.get_length()
	var buffer = file.get_buffer(file_len)
	return load_glb_from_buffer(buffer)

static func load_glb_from_buffer(buffer) -> Mesh:
	var spb = StreamPeerBuffer.new()
	spb.set_data_array(buffer)

	var buffer_len = buffer.size()
	if buffer_len < 12 or spb.get_32() != 0x46546C67 or spb.get_32() < 1 or spb.get_32() != buffer_len:
		return null
	
	var chunk_len = spb.get_32()
	var chunk_type = spb.get_32()
	if chunk_type != 0x4E4F534A: #Invalid JSON chunk
		return null
	if buffer_len - chunk_len - 12 <= 8: #no binary chunk
		return null
	
	var data = buffer.slice(20, 20 + chunk_len) #spb.get_buffer(chunk_len)
	
	
	#print(data.get_string_from_utf8())

	var test_json_conv = JSON.new()
	test_json_conv.parse(data.get_string_from_utf8())
	var json = test_json_conv.get_data()
	
	var bufferViews = json.get("bufferViews")

	var accessors = json.get("accessors", [])
	for acc in accessors:
		acc["buffer"] = bufferViews[acc.bufferView]
	
	var images = json.get("images", [])
	for img in images:
		img["buffer"] = bufferViews[img.bufferView]
		
	#print(accessors)
	
	var alignment = chunk_len % 4
	spb.seek(20 + chunk_len + alignment)
	
	var chunk_len2 = spb.get_32()
	var chunk_type2 = spb.get_32()
	if chunk_type2 != 0x004E4942: #Invalid Binary chunk
		return null
	#data = spb.get_buffer(chunk_len)
	data = buffer.slice(20 + chunk_len + alignment + 8, 20 + chunk_len + alignment + 8 + chunk_len2)
	
	for bv in bufferViews:
		bv.data = data.slice(bv.byteOffset, bv.byteOffset+bv.byteLength)
	
	var mesh: ArrayMesh = ArrayMesh.new()
	for mm in json.meshes:
		for primitive in mm.get("primitives", []):
			var vertices: PackedVector3Array = PackedVector3Array()
			var normals: PackedVector3Array = PackedVector3Array()
			var uvs: PackedVector2Array = PackedVector2Array()
			var uvs2: PackedVector2Array = PackedVector2Array()
			var colors: PackedColorArray = PackedColorArray()
			var indices: PackedInt32Array = PackedInt32Array()
			
			var arrays = []
			arrays.resize(Mesh.ARRAY_MAX)
			
			var a_index = primitive.get("indices", -1)
			var a_position = primitive.attributes.get("POSITION", -1)

			var a_normal = primitive.attributes.get("NORMAL", -1)
			var a_color = primitive.attributes.get("COLOR_0", -1)
			var a_tex0 = primitive.attributes.get("TEXCOORD_0", -1)
			var a_tex1 = primitive.attributes.get("TEXCOORD_1", -1)

			if a_position >= 0:
				vertices = read_vector3(vertices, accessors[a_position])
			if a_normal >= 0:
				normals = read_normal(normals, accessors[a_normal])
			if a_tex0 >= 0:
				uvs = read_vector2(uvs, accessors[a_tex0])
			if a_tex1 >= 0:
				uvs2 = read_vector2(uvs2, accessors[a_tex1])
			if a_color >= 0:
				colors = read_color(colors, accessors[a_color])
				
			if a_index >= 0:
				indices = read_scalar(indices, accessors[a_index])
			else:
				var count = vertices.size()
				indices.resize(count)
				for i in range(0, count, 3):
					indices[i+2] = i
					indices[i+1] = i+1
					indices[i] = i+2
			
			#print(indices.size())
			#accessors[a_index].buffer.data = null
			#print(accessors[a_index])
			
			if vertices.size() > 0:
				arrays[ArrayMesh.ARRAY_VERTEX] = vertices
			if normals.size() > 0:
				arrays[ArrayMesh.ARRAY_NORMAL] = normals
			if uvs.size() > 0:
				arrays[ArrayMesh.ARRAY_TEX_UV] = uvs
			if uvs2.size() > 0:
				arrays[ArrayMesh.ARRAY_TEX_UV2] = uvs2
			if indices.size() > 0:
				arrays[ArrayMesh.ARRAY_INDEX] = indices
			if colors.size() > 0:
				arrays[ArrayMesh.ARRAY_COLOR] = colors
			
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	#create textures
	for img in images:
		var image = Image.new()
		var _image_error
		match img.get("mimeType", ""):
			"image/png":
				_image_error = image.load_png_from_buffer(img.buffer.data)
			"image/jpeg":
				_image_error = image.load_jpg_from_buffer(img.buffer.data)
			"image/webp":
				_image_error = image.load_webp_from_buffer(img.buffer.data)
		var image_tex = ImageTexture.create_from_image(image)
		img["texture"] = image_tex
		img.buffer.data = null
	
	
	return mesh

static func read_scalar(output : PackedInt32Array, accessor):
	var spb = StreamPeerBuffer.new()
	spb.set_data_array(accessor.buffer.data)	
	var count = accessor.count
	output.resize(count)
	match int(accessor.componentType):
		5120: #byte
			for i in range(0, count, 3):
				output[i+2] = spb.get_8()
				output[i+1] = spb.get_8()
				output[i] = spb.get8()
		5121: #ubyte
			for i in range(0, count, 3):
				output[i+2] = spb.get_u8()
				output[i+1] = spb.get_u8()
				output[i] = spb.getu8()
		5122: #short
			for i in range(0, count, 3):
				output[i+2] = spb.get_16()
				output[i+1] = spb.get_16()
				output[i] = spb.get_16()
		5123: #ushort
			for i in range(0, count, 3):
				output[i+2] = spb.get_u16()
				output[i+1] = spb.get_u16()
				output[i] = spb.get_u16()
		5125: #uint
			for i in range(0, count, 3):
				output[i+2] = spb.get_u32()
				output[i+1] = spb.get_u32()
				output[i] = spb.get_u32()
		5126: #float
			for i in range(0, count, 3):
				output[i+2] = 	(int)(spb.get_float())
				output[i+1] = 	(int)(spb.get_float())
				output[i] = 	(int)(spb.get_float())
	return output

static func read_vector3(output : PackedVector3Array, accessor):
	var spb = StreamPeerBuffer.new()
	spb.set_data_array(accessor.buffer.data)	
	var count = accessor.count
	output.resize(count)
	var amax = accessor.get("max", [1, 1, 1])
	amax = Vector3(amax[0], amax[1], amax[2])
	var amin = accessor.get("min", [0, 0, 0])
	amin = Vector3(amin[0], amin[1], amin[2])
	match int(accessor.componentType):
		5120: #byte
			for i in range(count):
				output[i] = amin + amax * (Vector3(spb.get_u8(), spb.get_u8(), spb.get_u8()) / 255.0)
		5121: #ubyte
			for i in range(count):
				output[i] = amin + amax * (Vector3(spb.get_u8(), spb.get_u8(), spb.get_u8()) / 255.0)
		5122: #short
			for i in range(count):
				output[i] = amin + amax * (Vector3(spb.get_16(), spb.get_16(), spb.get_16()) / 65535.0)
		5123: #ushort
			for i in range(count):
				output[i] = amin + amax * (Vector3(spb.get_u16(), spb.get_u16(), spb.get_u16()) / 65535.0)
		5125: #uint
			for i in range(count):
				output[i] = amin + amax * (Vector3(spb.get_u32(), spb.get_u32(), spb.get_u32()) / 4294967295.0)
		5126: #float
			for i in range(count):
				output[i] = Vector3(spb.get_float(), spb.get_float(), spb.get_float())
	return output
	
static func read_normal(output : PackedVector3Array, accessor):
	var spb = StreamPeerBuffer.new()
	spb.set_data_array(accessor.buffer.data)	
	var count = accessor.count
	output.resize(count)
	match int(accessor.componentType):
		5120: #byte
			for i in range(count):
				output[i] = Vector3(spb.get_u8(), spb.get_u8(), spb.get_u8()) / 255.0
		5121: #ubyte
			for i in range(count):
				output[i] = Vector3(spb.get_u8(), spb.get_u8(), spb.get_u8()) / 255.0
		5122: #short
			for i in range(count):
				output[i] = Vector3(spb.get_16(), spb.get_16(), spb.get_16()) / 65535.0
		5123: #ushort
			for i in range(count):
				output[i] = Vector3(spb.get_u16(), spb.get_u16(), spb.get_u16()) / 65535.0
		5125: #uint
			for i in range(count):
				output[i] = Vector3(spb.get_u32(), spb.get_u32(), spb.get_u32()) / 4294967295.0
		5126: #float
			for i in range(count):
				output[i] = Vector3(spb.get_float(), spb.get_float(), spb.get_float())
	return output

static func read_vector2(output : PackedVector2Array, accessor):
	var spb = StreamPeerBuffer.new()
	spb.set_data_array(accessor.buffer.data)	
	var count = accessor.count
	output.resize(count)
	var amax = accessor.get("max", [1, 1])
	amax = Vector2(amax[0], amax[1])
	var amin = accessor.get("min", [0, 0])
	amin = Vector2(amin[0], amin[1])
	match int(accessor.componentType):
		5120: #byte
			for i in range(count):
				output[i] = amin + amax * (Vector2(spb.get_8(), spb.get_8()) / 255.0)
		5121: #ubyte
			for i in range(count):
				output[i] = amin + amax * (Vector2(spb.get_u8(), spb.get_u8()) / 255.0)
		5122: #short
			for i in range(count):
				output[i] = amin + amax * (Vector2(spb.get_16(), spb.get_16()) / 65535.0)
		5123: #ushort
			for i in range(count):
				output[i] = amin + amax * (Vector2(spb.get_u16(), spb.get_u16()) / 65535.0)
		5125: #uint
			for i in range(count):
				output[i] = amin + amax * (Vector2(spb.get_u32(), spb.get_u32()) / 4294967295.0)
		5126: #float
			for i in range(count):
				output[i] = Vector2(spb.get_float(), spb.get_float())
	return output

static func read_color(output : PackedColorArray, accessor):
	var spb = StreamPeerBuffer.new()
	spb.set_data_array(accessor.buffer.data)
	var count = accessor.count
	var type = accessor.type
	output.resize(count)
	if type == "VEC3":
		match int(accessor.componentType):
			5120: #byte
				for i in range(count):
					output[i] = Color(spb.get_8() / 255.0, spb.get_8() / 255.0, spb.get_8() / 255.0)
			5121: #ubyte
				for i in range(count):
					output[i] = Color(spb.get_u8() / 255.0, spb.get_u8() / 255.0, spb.get_u8() / 255.0)
			5122: #short
				for i in range(count):
					output[i] = Color(spb.get_16() / 65535.0, spb.get_16() / 65535.0, spb.get_16() / 65535.0)
			5123: #ushort
				for i in range(count):
					output[i] = Color(spb.get_u16() / 65535.0, spb.get_u16() / 65535.0, spb.get_u16() / 65535.0)
			5125: #uint
				for i in range(count):
					output[i] = Color(spb.get_u32() / 4294967295.0, spb.get_u32() / 4294967295.0, spb.get_u32() / 4294967295.0)
			5126: #float
				for i in range(count):
					output[i] = Color(spb.get_float(), spb.get_float(), spb.get_float())
	elif type == "VEC4":
		match int(accessor.componentType):
			5120: #byte
				for i in range(count):
					output[i] = Color(spb.get_8() / 255.0, spb.get_8() / 255.0, spb.get_8() / 255.0, spb.get_8() / 255.0)
			5121: #ubyte
				for i in range(count):
					output[i] = Color(spb.get_u8() / 255.0, spb.get_u8() / 255.0, spb.get_u8() / 255.0, spb.get_u8() / 255.0)
			5122: #short
				for i in range(count):
					output[i] = Color(spb.get_16() / 65535.0, spb.get_16() / 65535.0, spb.get_16() / 65535.0, spb.get_16() / 65535.0)
			5123: #ushort
				for i in range(count):
					output[i] = Color(spb.get_u16() / 65535.0, spb.get_u16() / 65535.0, spb.get_u16() / 65535.0, spb.get_u16() / 65535.0)
			5125: #uint
				for i in range(count):
					output[i] = Color(spb.get_u32() / 4294967295.0, spb.get_u32() / 4294967295.0, spb.get_u32() / 4294967295.0, spb.get_u32() / 4294967295.0)
			5126: #float
				for i in range(count):
					output[i] = Color(spb.get_float(), spb.get_float(), spb.get_float(), spb.get_float())
	return output
