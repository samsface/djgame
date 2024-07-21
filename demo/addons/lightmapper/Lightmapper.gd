@tool
extends SubViewport

enum BakeMode {AO, COLOR, COLOR_AO, CURVATURE, COLOR_CURVATURE, COLOR_CURVATURE_AO, COMBINATION, COLOR_COMBINATION}

@export var refresh: bool: set = set_refresh

@export var mesh_node: NodePath
@export var always_render : bool = false
@export var mode: BakeMode = BakeMode.AO
#Model from: https://jcapioso.gumroad.com/l/yaqepq
var meshinst
var prev_image
var frame = -1
var previous_bake = null

var color_shader = preload("res://addons/lightmapper/color_shader.tres")
var ao_shader = preload("res://addons/lightmapper/ao_shader.tres")
var curvature_shader = preload("res://addons/lightmapper/curvature_shader.tres")
var combination_shader = preload("res://addons/lightmapper/combination_shader.tres")

func set_refresh(_newval):
	refresh_scene()
	pass
	
func _ready():
	refresh_scene()

func refresh_scene():
	await get_tree().process_frame
	meshinst = get_node(mesh_node)
	
	var old_mesh = meshinst.mesh
	if old_mesh == null:
		return
	
	if OS.get_name() == "HTML5" or OS.has_feature('JavaScript'):
		print("keep UV2")
	else:
		var new_mesh = UVPack.builtin_unwrap(old_mesh, 0.01)
		set_mesh(new_mesh)
	
	var texture = get_texture()

	#texture.flags = Texture2D.FLAG_FILTER
	
	var VC2 = $VC2
	var VP2 = $VC2/Viewport2
	var VC = $VC2/Viewport2/VC
	var VP = $VC2/Viewport2/VC/Viewport
	
	"""
	if OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES2:
		VP.keep_3d_linear = false
		#VP2.keep_3d_linear = false
	else:
		VP.keep_3d_linear = true
		#VP2.keep_3d_linear = true
	"""
	
	var material = meshinst.get_surface_override_material(0)
	if material == null:
		return
	material.set_shader_parameter("light_texture", texture)
	
	VC.size = size
	#VP.size = size
	VC.material.set_shader_parameter("pixels_size", Vector2(1.0 / size.x, 1.0 / size.y))
	
	VC2.size = size
	#VP2.size = size
	VC2.material.set_shader_parameter("pixels_size", Vector2(1.0 / size.x, 1.0 / size.y))
	
	var mesh = meshinst.get_mesh()
	var lightmap_mat = $VC2/Viewport2/VC/Viewport/lightmap_mesh.get_surface_override_material(0)
	var aabb = mesh.get_aabb()
	var arrays = mesh.surface_get_arrays(0)
	
	lightmap_mat.set_shader_parameter("bound_start", aabb.position)
	lightmap_mat.set_shader_parameter("bound_size", aabb.size)
	
	var itex = create_vertex_tex(aabb, arrays[Mesh.ARRAY_INDEX], arrays[Mesh.ARRAY_VERTEX], arrays[Mesh.ARRAY_TEX_UV], arrays[Mesh.ARRAY_TEX_UV2])
	lightmap_mat.set_shader_parameter("tri_count", itex[0])
	lightmap_mat.set_shader_parameter("tris", itex[1])
	lightmap_mat.set_shader_parameter("uvs", itex[2])
	#lightmap_mat.set_shader_param("lightmap_tex", texture)
	
	if OS.get_name() == "HTML5":
		VC.material.set_shader_parameter("prev_tex", null)
		VC2.material.set_shader_parameter("prev_tex", null)
	else:
		VC.material.set_shader_parameter("prev_tex", VP2.get_texture())
		VC2.material.set_shader_parameter("prev_tex", texture)
	
	frame = 0
	VC2.material.set_shader_parameter("frame", frame)
	VC.material.set_shader_parameter("frame", frame)
	
	var blur = true
	if mode == BakeMode.CURVATURE or mode == BakeMode.COLOR_CURVATURE:
		lightmap_mat.set_shader(curvature_shader)
	elif mode == BakeMode.COLOR:
		lightmap_mat.set_shader(color_shader)
		blur = false
	elif mode == BakeMode.COMBINATION or mode == BakeMode.COLOR_COMBINATION:
		lightmap_mat.set_shader(combination_shader)
	else:
		lightmap_mat.set_shader(ao_shader)
		
	VC.material.set_shader_parameter("blur", blur)
	VC2.material.set_shader_parameter("blur", blur)
	VC.material.set_shader_parameter("blend_mode", 0)
	VC2.material.set_shader_parameter("blend_mode", 0)
	
	VP2.set_transparent_background(false)
	VP.set_transparent_background(false)
	set_transparent_background(false)
	await get_tree().process_frame
	VP2.set_transparent_background(true)
	VP.set_transparent_background(true)
	set_transparent_background(true)
	
	VP2.set_update_mode(self.UPDATE_ALWAYS)
	VP.set_update_mode(self.UPDATE_ALWAYS)
	self.set_update_mode(self.UPDATE_ALWAYS)
	
	VP.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
	self.set_clear_mode(SubViewport.CLEAR_MODE_ONCE)
	VP2.set_clear_mode(SubViewport.CLEAR_MODE_ONCE)
	
	await get_tree().process_frame
	
	#var prev_image3 = $VC2/Viewport2/VC/Viewport.get_texture().get_image()
	#prev_image3.save_png("D:/Projects/Godot/Godot_4/Lightmapper/Out/export.png")
	

func set_mesh(mesh):
	var mi1 = get_node("../MeshInstance")
	var mi2 = get_node("../MeshInstance_comp")
	var lm = get_node("VC2/Viewport2/VC/Viewport/lightmap_mesh")
	lm.mesh = mesh
	mi1.mesh = mesh
	mi2.mesh = mesh

func set_texture(texture):
	var mi1 = get_node("../MeshInstance")
	var mi2 = get_node("../MeshInstance_comp")
	var lm = get_node("VC2/Viewport2/VC/Viewport/lightmap_mesh")
	mi1.get_surface_override_material(0).set_shader_parameter("albedo_texture", texture)
	mi2.get_surface_override_material(0).set_texture(0, texture)
	lm.get_surface_override_material(0).set_shader_parameter("main_tex", texture)

func get_output_texture():
	meshinst = get_node(mesh_node)
	var material = meshinst.get_surface_override_material(0)
	return material.get_shader_parameter("light_texture")

func get_output_mesh():
	meshinst = get_node(mesh_node)
	return meshinst.mesh

func set_mesh_rotation_x(rad):
	var mi1 = get_node("../MeshInstance")
	var mi2 = get_node("../MeshInstance_comp")
	mi1.transform.basis = Basis(Vector3(1, 0, 0), rad)
	mi2.transform.basis = Basis(Vector3(1, 0, 0), rad)

func _process(_delta):
	if true:# OS.get_name() == "HTML5":
		prev_image = get_texture().get_image()
		var imtex = ImageTexture.create_from_image(prev_image)	
		$VC2.material.set_shader_parameter("prev_tex", imtex)
		
		var prev_image2 = $VC2/Viewport2.get_texture().get_image()
		var imtex2 = ImageTexture.create_from_image(prev_image2)
		$VC2/Viewport2/VC.material.set_shader_parameter("prev_tex", imtex2)

	var last_frame = 80 #65
	if mode == BakeMode.COLOR:
		last_frame = 4
		$VC2.material.set_shader_parameter("blend_mode", -1)
		$VC2/Viewport2/VC.material.set_shader_parameter("blend_mode", -1)
	
		
	if frame >= 0:
		frame += 1
		$VC2.material.set_shader_parameter("frame", frame)
		$VC2/Viewport2/VC.material.set_shader_parameter("frame", frame)
		
		if mode == BakeMode.COLOR_AO:
			if frame == last_frame and !always_render:
				bake_color()
				$VC2.material.set_shader_parameter("blend_mode", 0)
				$VC2/Viewport2/VC.material.set_shader_parameter("blend_mode", 0)
			if frame == last_frame + 1 and !always_render:
				$VC2.material.set_shader_parameter("blend_mode", 1)
				$VC2/Viewport2/VC.material.set_shader_parameter("blend_mode", -1)
			if frame == last_frame + 2 and !always_render:
				stop_baking()
		elif mode == BakeMode.COLOR_CURVATURE:
			if frame == last_frame and !always_render:
				bake_color()
				$VC2.material.set_shader_parameter("blend_mode", 0)
				$VC2/Viewport2/VC.material.set_shader_parameter("blend_mode", 0)
			if frame == last_frame + 1 and !always_render:
				$VC2.material.set_shader_parameter("blend_mode", 2)
				$VC2/Viewport2/VC.material.set_shader_parameter("blend_mode", -1)
			if frame == last_frame + 2 and !always_render:
				stop_baking()
		elif mode == BakeMode.COLOR_COMBINATION:
			if frame == last_frame and !always_render:
				bake_color()
				$VC2.material.set_shader_parameter("blend_mode", 0)
				$VC2/Viewport2/VC.material.set_shader_parameter("blend_mode", 0)
			if frame == last_frame + 1 and !always_render:
				$VC2.material.set_shader_parameter("blend_mode", 6)
				$VC2/Viewport2/VC.material.set_shader_parameter("blend_mode", -1)
			if frame == last_frame + 2 and !always_render:
				stop_baking()
		elif mode == BakeMode.COLOR_CURVATURE_AO:
			if frame == last_frame and !always_render:
				var lightmap_mat = $VC2/Viewport2/VC/Viewport/lightmap_mesh.get_surface_override_material(0)
				lightmap_mat.set_shader(curvature_shader)
				prev_image = get_texture().get_image()
				previous_bake = ImageTexture.create_from_image(prev_image)
			if frame == last_frame*3 and !always_render:
				bake_color()
				$VC2.material.set_shader_parameter("blend_mode", 0)
				$VC2/Viewport2/VC.material.set_shader_parameter("blend_mode", 0)
			if frame == last_frame*3 + 1 and !always_render:
				$VC2.material.set_shader_parameter("previous_bake", previous_bake)
				$VC2.material.set_shader_parameter("blend_mode", 3)
				$VC2/Viewport2/VC.material.set_shader_parameter("blend_mode", -1)
			if frame == last_frame*3 + 2 and !always_render:
				stop_baking()	
		else:
			if frame == last_frame and !always_render:
				stop_baking()


func bake_color():
	var lightmap_mat = $VC2/Viewport2/VC/Viewport/lightmap_mesh.get_surface_override_material(0)
	lightmap_mat.set_shader(color_shader)
	var VC = $VC2
	var VC2 = $VC2/Viewport2/VC
	VC.material.set_shader_parameter("blur", false)
	VC2.material.set_shader_parameter("blur", false)	
		
func stop_baking():
	frame = -1
	$VC2/Viewport2.set_update_mode(self.UPDATE_DISABLED)
	$VC2/Viewport2/VC/Viewport.set_update_mode(self.UPDATE_DISABLED)
	self.set_update_mode(self.UPDATE_DISABLED)	

func create_vertex_tex(aabb, indexes, vertexes, uvs, uv2s):
	var isize = 256
	var i = 0
	var data = PackedByteArray([])
	data.resize(isize * isize * 4)
	var data_uv = PackedByteArray([])
	data_uv.resize(isize * isize * 4)
	
	var pos = aabb.position
	var scale = aabb.size
	while i*8 < len(data) and i < len(indexes):
		var vert = vertexes[indexes[i]]
		var rescaled = (vert - pos) / scale
		data[i*8] = int(rescaled.x * 255)
		data[i*8+1] = int(rescaled.y * 255)
		data[i*8+2] = int(rescaled.z * 255)
		data[i*8+3] = 255
		data[i*8+4] = int((rescaled.x * 255 - floor(rescaled.x * 255)) * 255)
		data[i*8+5] = int((rescaled.y * 255 - floor(rescaled.y * 255)) * 255)
		data[i*8+6] = int((rescaled.z * 255 - floor(rescaled.z * 255)) * 255)
		data[i*8+7] = 255
		
		var uv = uvs[indexes[i]]
		var uv2 = uv2s[indexes[i]]
		data_uv[i*8] = int(uv.x * 255)
		data_uv[i*8+1] = int(uv.y * 255)
		data_uv[i*8+2] = int(uv2.x * 255)
		data_uv[i*8+3] = int(uv2.y * 255)
		
		i += 1

	var image = Image.create_from_data(isize, isize, false, Image.FORMAT_RGBA8, data)	
	#image.save_png("res://Data/exportimage.png")
	var itex = ImageTexture.create_from_image(image) #,0
	
	var uv_image = Image.create_from_data(isize, isize, false, Image.FORMAT_RGBA8, data_uv)	
	var uv_tex = ImageTexture.create_from_image(uv_image) #,0
	
	@warning_ignore("integer_division")
	return [i/3, itex, uv_tex]
