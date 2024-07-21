extends CanvasLayer

@onready var models = [
	preload("res://models/blacksmith_building_blacksmith_red.res"), 
	preload("res://models/windmill_building_windmill_red.res"), 
	preload("res://models/house1_building_B_Cube_936.res")]
@onready var textures = [
	preload("res://models/citybits_texture.png"), 
	preload("res://models/hexagons_medieval.png")]

func _ready():
	var SizeButton = $SizeOptionButton
	SizeButton.add_item("64x64")
	SizeButton.add_item("128x128")
	SizeButton.add_item("256x256")
	SizeButton.add_item("512x512")
	SizeButton.add_item("1024x1024")
	SizeButton.add_item("2048x2048")
	SizeButton.connect("item_selected", Callable(self, "size_changed"))
	
	var MeshButton = $MeshOptionButton
	MeshButton.add_item("blacksmith")
	MeshButton.add_item("windmill")
	MeshButton.add_item("house")
	MeshButton.connect("item_selected", Callable(self, "mesh_changed"))
	
	var BakeButton = $BakeOptionButton

	BakeButton.add_item("AO")
	BakeButton.add_item("Color")
	BakeButton.add_item("Color + AO")
	BakeButton.add_item("Curvature")
	BakeButton.add_item("Color + Curvature")
	BakeButton.add_item("Color + Curvature + AO")
	BakeButton.add_item("Combination")
	BakeButton.add_item("Color + Combination")
	BakeButton.selected = get_node("../Lightmapper").mode	
	BakeButton.connect("item_selected", Callable(self, "bake_changed"))
	
	var _r1 = $LoadMeshButton.connect("pressed", Callable(self, "load_mesh_pressed"))
	var _r2 = $LoadTextureButton.connect("pressed", Callable(self, "load_texture_pressed"))
	var _r3 = $SaveMeshButton.connect("pressed", Callable(self, "save_mesh_pressed"))
	var _r4 = $SaveTextureButton.connect("pressed", Callable(self, "save_texture_pressed"))
	
	SizeButton.select(2)
	

func size_changed(value):
	var size = 64
	match value:
		0: size = 64
		1: size = 128
		2: size = 256
		3: size = 512
		4: size = 1024
		5: size = 2048
	get_node("../Lightmapper").size = Vector2(size, size)
	get_node("../Lightmapper").refresh_scene()
	
func mesh_changed(value):
	var lightmapper = get_node("../Lightmapper")
	var model = models[value]
	lightmapper.set_mesh(model)

	if value == 2:
		lightmapper.set_mesh_rotation_x(PI * 0.5)
		lightmapper.set_texture(textures[0])
	else:
		lightmapper.set_mesh_rotation_x(0.0)
		lightmapper.set_texture(textures[1])
	
	get_node("../Lightmapper").refresh_scene()

func bake_changed(value):
	var lightmapper = get_node("../Lightmapper")
	lightmapper.mode = value
	lightmapper.refresh_scene()

func load_mesh_pressed():
	$FileManager.load_mesh(self, "mesh_loaded")
	pass
	
func load_texture_pressed():
	$FileManager.load_image(self, "image_loaded")
	pass

func save_mesh_pressed():
	var lightmapper = get_node("../Lightmapper")
	var mesh = lightmapper.get_output_mesh()
	$FileManager.save_mesh(mesh)
	pass
	
func save_texture_pressed():
	var lightmapper = get_node("../Lightmapper")
	var texture = lightmapper.get_output_texture()
	var image = texture.get_data()
	$FileManager.save_image(image)
	pass

func mesh_loaded(_mesh):
	var lightmapper = get_node("../Lightmapper")
	lightmapper.set_mesh(_mesh)
	lightmapper.refresh_scene()
	pass
	
func image_loaded(_texture):
	#print(_texture.get_size())
	var lightmapper = get_node("../Lightmapper")
	lightmapper.set_texture(_texture)
	lightmapper.refresh_scene()
	pass
