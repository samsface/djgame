extends Node

signal read_completed

var js_callback = JavaScriptBridge.create_callback(load_handler);
var js_interface = null

func load_image(callback_obj, callback_fun):
	if js_interface != null:
		load_image_html(callback_obj, callback_fun)
	else:
		load_image_pc(callback_obj, callback_fun)

func load_mesh(callback_obj, callback_fun):
	if js_interface != null:
		load_mesh_html(callback_obj, callback_fun)
	else:
		load_mesh_pc(callback_obj, callback_fun)
		
func save_image(image):
	if js_interface != null:
		save_image_html(image)
	else:
		save_image_pc(image)
		
func save_mesh(mesh):
	if js_interface != null:
		save_mesh_html(mesh)
	else:
		save_mesh_pc(mesh)

#----------------

func _ready():
	if OS.get_name() == "HTML5" and OS.has_feature('JavaScript'):
		_define_js()
		js_interface = JavaScriptBridge.get_interface("_HTML5FileExchange");

func _define_js()->void:
	#Define JS script
	JavaScriptBridge.eval("""
	var _HTML5FileExchange = {};
	_HTML5FileExchange.upload = function(gd_callback, type) {
		canceled = true;
		var input = document.createElement('INPUT'); 
		input.setAttribute("type", "file");
		if (type === "image") {
			input.setAttribute("accept", "image/png, image/jpeg, image/webp");
		}
		if (type === "mesh") {
			input.setAttribute("accept", ".obj, super.glb");
		}
		input.click();
		input.addEventListener('change', event => {
			if (event.target.files.length > 0){
				canceled = false;}
			var file = event.target.files[0];
			var reader = new FileReader();
			this.fileType = file.type;
			this.fileName = file.name;
			reader.readAsArrayBuffer(file);
			reader.onloadend = (evt) => { // Since here's it's arrow function, "this" still refers to _HTML5FileExchange
				if (evt.target.readyState == FileReader.DONE) {
					this.result = evt.target.result;
					gd_callback(); // It's hard to retrieve value from callback argument, so it's just for notification
				}
			}
		  });
	}
	""", true)

func load_handler(_args):
	emit_signal("read_completed")

func load_mesh_pc(callback_obj, callback_fun):
	var conns = get_incoming_connections()
	for con in conns:
		if con.signal == $FileDialog.file_selected:
			con.signal.disconnect(con.callable)
	
	$FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	$FileDialog.show()
	$FileDialog.set_filters(PackedStringArray(["*.obj ; OBJ mesh", "*.glb ; GLTF binary mesh"]))
	var _r = $FileDialog.connect("file_selected", Callable(self, "mesh_selected").bind(callback_obj, callback_fun))
	
func mesh_selected(path, callback_obj, callback_fun):
	var extension = path.get_extension()
	if extension == "obj":
		var mesh = ObjParse.load_obj(path)
		callback_obj.call(callback_fun, mesh)
	elif extension == "glb":
		var mesh = GltfParse.load_glb(path)
		callback_obj.call(callback_fun, mesh)
	
func load_mesh_html(callback_obj, callback_fun):
	if OS.get_name() != "HTML5" or !OS.has_feature('JavaScript'):
		return

	js_interface.upload(js_callback, "mesh");

	await self.read_completed
	
	var _type = js_interface.fileType;
	var data = JavaScriptBridge.eval("_HTML5FileExchange.result", true) # interface doesn't work as expected for some reason
	var mesh = null
	match js_interface.fileName.get_extension():
		"obj":
			mesh = ObjParse.load_obj_from_buffer(data.get_string_from_utf8(), {})
		"glb":
			mesh = GltfParse.load_glb_from_buffer(data)
	callback_obj.call(callback_fun, mesh)

func load_image_pc(callback_obj, callback_fun):
	var conns = get_incoming_connections()
	for con in conns:
		if con.signal == $FileDialog.file_selected:
			con.signal.disconnect(con.callable)
	
	$FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	$FileDialog.show_modal()
	$FileDialog.set_filters(PackedStringArray(["*.png, *.jpg, *.jpeg ; Supported Images"]))
	var _r = $FileDialog.connect("file_selected", Callable(self, "image_selected").bind(callback_obj, callback_fun))
	
func image_selected(_path, callback_obj, callback_fun):
	var image = Image.new()
	image.load(_path)
	var image_tex = ImageTexture.create_from_image(image)	
	callback_obj.call(callback_fun, image_tex)

func load_image_html(callback_obj, callback_fun):
	if OS.get_name() != "HTML5" or !OS.has_feature('JavaScript'):
		return

	js_interface.upload(js_callback, "image");

	await self.read_completed
	
	var imageType = js_interface.fileType;
	var imageData = JavaScriptBridge.eval("_HTML5FileExchange.result", true) # interface doesn't work as expected for some reason
	
	var image = Image.new()
	var image_error
	match imageType:
		"image/png":
			image_error = image.load_png_from_buffer(imageData)
		"image/jpeg":
			image_error = image.load_jpg_from_buffer(imageData)
		"image/webp":
			image_error = image.load_webp_from_buffer(imageData)
		var invalidType:
			print("Unsupported file format - %s." % invalidType)
			return
	
	if image_error:
		print("An error occurred while trying to display the image.")
	
	var image_tex = ImageTexture.create_from_image(image)
	callback_obj.call(callback_fun, image_tex)


func save_image_pc(image):
	var conns = get_incoming_connections()
	for con in conns:
		if con.signal == $FileDialog.file_selected:
			con.signal.disconnect(con.callable)
	
	$FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	$FileDialog.show()
	$FileDialog.set_filters(PackedStringArray(["*.png ; PNG image"]))

	var _r = $FileDialog.connect("file_selected", Callable(self, "save_image_selected").bind(image))
	
func save_image_selected(path, image):
	image.save_png(path)

func save_image_html(image):
	if OS.get_name() != "HTML5" or !OS.has_feature('JavaScript'):
		return
	
	var buffer = image.save_png_to_buffer()
	JavaScriptBridge.download_buffer(buffer, "texture.png")


func save_mesh_pc(mesh):
	var conns = get_incoming_connections()
	for con in conns:
		if con.signal == $FileDialog.file_selected:
			con.signal.disconnect(con.callable)
	
	$FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	$FileDialog.show()
	$FileDialog.set_filters(PackedStringArray(["*.obj ; OBJ mesh"]))

	var _r = $FileDialog.connect("file_selected", Callable(self, "save_mesh_selected").bind(mesh))
	
func save_mesh_selected(path, mesh):
	var output = ObjParse.convert_to_obj(mesh, "edited_mesh")
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(output)

func save_mesh_html(mesh):
	if OS.get_name() != "HTML5" or !OS.has_feature('JavaScript'):
		return
		
	var output = ObjParse.convert_to_obj(mesh, "edited_mesh")
	var buffer = output.to_utf8_buffer()
	JavaScriptBridge.download_buffer(buffer, "newmesh.obj")
