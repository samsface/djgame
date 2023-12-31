extends Control
class_name PDPatch

signal loading_done

@export var root := false

var undo_ := UndoRedo.new()
var canvas:String
var lines := []
var drag_selection_box_
var drag_threshold_ := 0.5
var initial_click_position_ := Vector2.ZERO
var object_count_ := 0
var patch_path
var inlets := []
var outlets := []
var is_loading := false

var patch_file_handle_ := PDPatchFile.new()
var cursor_:Area2D
var supress_messages := false

var mode_

func _ready() -> void:
	cursor_ = preload("res://widgets/cursor/cursor.tscn").instantiate()
	add_child(cursor_)
	
	get_viewport().get_window().title = patch_path.get_file()

func enter_mode_(mode) -> void:
	if mode_:
		mode_._cancel()
		remove_child(mode_)

	mode_ = mode
	
	if mode_:
		mode_.tree_exited.connect(exit_mode_)
		add_child(mode_)

func exit_mode_() -> void:
	mode_ = null

class InputEventDrag extends InputEventMouseMotion:
	pass

func _input(event: InputEvent):
	if event.is_action_pressed("save"):
		save()
		
	if event.is_action_pressed("super_save"):
		super_save_()
	
	if event is InputEventMouseMotion:
		cursor_.position = get_global_mouse_position()

	if not mode_:
		enter_mode_(HoverMode.new())
		
	if mode_.block():
		return

	if SelectionBus.hovering_slot:
		if event.is_action_pressed("right_click"):
			enter_mode_(ConnectMode.new(SelectionBus.hovering_slot))
			return

	if PlayMode.test(event, SelectionBus.selection_):
		enter_mode_(PlayMode.new())

	elif MoveMode.test(event, SelectionBus.selection_):
		enter_mode_(MoveMode.new(SelectionBus.selection_))

	elif SelectMode.test(event, SelectionBus.selection_):
		enter_mode_(SelectMode.new(SelectionBus.selection_))
		
	elif SearchMode.test(event, SelectionBus.selection_):
		enter_mode_(SearchMode.new())
		
	elif EditMode.test(event, SelectionBus.selection_):
		enter_mode_(EditMode.new(SelectionBus.selection_))

	elif event.is_action_pressed("ui_down"):
		open_patch_in_new_window_()
	
	elif event.is_action_pressed("ui_cancel"):
		SelectionBus.clear_selection()
		
	elif event.is_action_pressed("select_all"):
		SelectionBus.clear_selection()
		for node in get_children():
			if "selectable" in node:
				SelectionBus.add_to_selection(node)
	
	elif event.is_action_pressed("delete"):
		delete_()

	elif event.is_action_pressed("copy"):
		copy_()

	elif event.is_action_pressed("paste"):
		paste_()

	elif event.is_action_pressed("redo"):
		undo_.redo()

	elif event.is_action_pressed("undo"):
		undo_.undo()

	elif event.is_action_pressed("click"):
		initial_click_position_ = get_global_mouse_position()

		if not SelectionBus.hovering:
			SelectionBus.clear_selection()
		
		if SelectionBus.selection_.size() <= 1:
			if SelectionBus.hovering:
				SelectionBus.change_selection(SelectionBus.hovering)

	elif event is InputEventMouseMotion and initial_click_position_ != Vector2.ZERO:
		if get_global_mouse_position().distance_to(initial_click_position_) > drag_threshold_:
			initial_click_position_ = Vector2.ZERO
			_input(InputEventDrag.new())

	elif event.is_action_released("click"):
		initial_click_position_ = Vector2.ZERO

		if SelectionBus.selection_.size() > 1:
			if SelectionBus.hovering:
				SelectionBus.change_selection(SelectionBus.hovering)

func get_connected_cables_(node:PDNode)-> Array:
	var res := []
	for object in get_children():
		if object is PDCable:
			if object.from.parent == node:
				res.push_back(object)
			elif object.to.parent == node:
				res.push_back(object)

	return res

################################################################################
# open patch in new window
################################################################################

func open_patch_in_new_window_() -> void:
	get_tree().root.get_viewport().gui_embed_subwindows = false
	var viewer = load("res://widgets/viewer/viewer.tscn").instantiate()
	viewer.add(PureData.files["pd-clock.pd"])
	var window := Window.new()
	window.size = get_viewport().size
	window.add_child(viewer)
	window.close_requested.connect(window.queue_free)
	get_tree().root.add_child(window)

################################################################################
# deleting stuff
################################################################################

func delete_() -> void:
	var objects_to_delete = SelectionBus.selection_.duplicate()
	var cables_to_delete := []
	var ghost_objects := []
	for object in objects_to_delete:
		if object is PDNode:
			cables_to_delete += get_connected_cables_(object)
			ghost_objects += object.ghost_rs

	objects_to_delete += ghost_objects
	objects_to_delete += cables_to_delete

	undo_.create_action("delete")
	for object in objects_to_delete:
		undo_.add_undo_reference(object)
	undo_.add_do_method(delete_do_.bind(objects_to_delete))
	undo_.add_undo_method(delete_undo_.bind(objects_to_delete))
	undo_.commit_action()

func delete_do_(objects_to_delete:Array) -> void:
	for object in objects_to_delete:
		remove_child(object)

func delete_undo_(objects_to_delete:Array) -> void:
	for object in objects_to_delete:
		add_child(object)

################################################################################
# copy paste
################################################################################

func copy_() -> void:
	DisplayServer.clipboard_set(serialize_(SelectionBus.selection_))

func serialize_(selection:Array) -> String:
	var coords
	var rejigged_indexs := {}

	var str := "#N canvas 757 493 971 650 12;\n"

	for node in selection:
		if node is PDNode:
			if not node.visible:
				continue
			if node.text.begins_with("coords"):
				coords = node
			else:
				str += "#X " + node.text + ";\n"
				rejigged_indexs[node] = rejigged_indexs.size()

	for node in selection:
		if not node.visible:
			continue
		if node is PDCable:
			var from = rejigged_indexs.get(node.from.parent)
			var to = rejigged_indexs.get(node.to.parent)
			# protect against selecting the cable but the node
			if from != null and to != null:
				str += "#X connect %s %s %s %s;\n" % [from, node.from.index, to, node.to.index]

	if coords:
		str += "#X " + coords.text + ";\n"

	return str

func paste_() -> void:
	undo_.create_action("paste")
	
	var clipboard = DisplayServer.clipboard_get()

	is_loading = false

	var lines = clipboard.split(';')
	var object_count = object_count_
	
	SelectionBus.clear_selection()

	for line in lines:
		SelectionBus.add_to_selection(parse_command(line, object_count))

	var center_point := SelectionBus.get_center_point()
	var move = get_global_mouse_position() - center_point
	
	for obj in SelectionBus.selection_:
		if obj is PDNode:
			obj.position += move
			obj._move_end()

		undo_.add_do_reference(obj)
		undo_.add_do_method(try_add_child_.bind(obj))
		undo_.add_undo_method(remove_child.bind(obj))

	undo_.commit_action()

	is_loading = true
	loading_done.emit()

################################################################################
# adding nodes
################################################################################

func add_node_(node_name:String):
	var n = add_node__(node_name)

	undo_.create_action("add_node")
	undo_.add_do_method(add_child.bind(n))
	undo_.add_do_reference(n)
	undo_.add_undo_method(remove_child.bind(n))
	undo_.commit_action()

func add_node__(node_name:String):
	var node = preload("res://objects/graph_node.tscn").instantiate()
	node.name = node_name
	node.canvas = self
	node.text = node_name

	node.begin_resize.connect(begin_resize_.bind(node))
	node.end_resize.connect(end_resize_.bind(node))

	return node

################################################################################
# resizing nodes
################################################################################

func begin_resize_(node) -> void:
	if not mode_ or not mode_.block():
		pass

func end_resize_(node:PDNode) -> void:
	pass

func clear_connections_(node:PDNode) -> void:
	for cable in get_connected_cables_(node):
		cable.call_disconnect()

func add_connections_(node:PDNode) -> void:
	for cable in get_connected_cables_(node):
		cable.call_connect()

################################################################################

class PDParseContext:
	var path:String
	
	func _init(file) -> void:
		path = file.substr(0, file.length() - file.get_file().length())

func parse_command(command:String, object_idx_offset:int = 0) -> Node:
	command = command.replace('\n', ' ')
	command = command.replace('  ', ' ')

	if command[0] == ' ':
		command = command.substr(1)

	if command.is_empty():
		return null

	var args = command.split(' ')

	var it = PureData.IteratePackedStringArray.new()
	it.packed_string_ = args
	
	var canvas = it.next()
	if canvas == null:
		push_error("canvas was null")
		return null

	var message = it.next()
	if message == null:
		push_error("message was null: '%s'" % command)
		return null

	if message == 'connect':
		var from = int(it.next()) + object_idx_offset
		var outlet = int(it.next())
		var to = int(it.next()) + object_idx_offset
		var inlet = int(it.next())

		return add_connection_(from, outlet, to, inlet)
	elif message == 'canvas':
		return null
	else:
		var res = add_node__(it.join())
		add_child(res)
		return res

func find_node_by_object_id(id:int) -> Node:
	for node in get_children():
		if node is PDNode:
			if node.index == id:
				return node
	
	return null

func add_connection_(from_object:int, outlet:int, to_object:int, inlet:int) -> PDCable:
	var from_node = find_node_by_object_id(from_object)
	if not from_node:
		push_error("from object does not exit")
		return
		
	var to_node = find_node_by_object_id(to_object)
	if not to_node:
		push_error("from object does not exit")
		return
	
	var outlet_node = from_node.get_outlet(outlet)
	if not outlet_node:
		push_error("from object does not exit")
		return

	var inlet_node = to_node.get_inlet(inlet)
	if not inlet_node:
		push_error("from object does not exit")
		return

	var cable = preload("res://objects/cable.tscn").instantiate()
	cable.from = outlet_node
	cable.to = inlet_node
	add_child(cable)
	#cable.global_position = Vector2.ZERO
	cable.call_connect()
	
	return cable

func get_all_objects_(filter:String) -> Array:
	var res := []
	for node in get_children():
		if node is PDNode and node.text.contains(filter):
			res.push_back(node)
	
	return res

func open(path:String) -> bool:
	prints("open_patch", path)
	
	patch_path = path

	var p = ProjectSettings.globalize_path(patch_path)

	if not patch_file_handle_.open(p):
		push_error("couldn't open patch")
		return false

	canvas = "pd-" + patch_path.get_file()
	
	print("parsing %s" % path)
	supress_messages = true
	var lines := FileAccess.get_file_as_string(patch_path).split(';')
	for line in lines:
		parse_command(line)
	supress_messages = false

	var model := NodeDb.N.new()
	model.title = path.get_file().replace(".pd", "")
	model.specialized = load("res://objects/special/subpatch.tscn").duplicate()
	model.specialized.set_meta("path", patch_path)
	model.instance = true
	model.visible_in_subpatch = true
	
	for i in get_all_objects_("inlet").size():
		model.inputs.push_back(NodeDb.C.new("input", "any"))
		
	for i in get_all_objects_("outlet").size():
		model.outputs.push_back(NodeDb.C.new("input", "any"))

	NodeDb.db[model.title] = model

	PureData.files[canvas] = self

	is_loading = true
	loading_done.emit()
	
	if is_inside_tree():
		PureData.send_message(canvas, ["menusave"])

	print("done parsing")
	
	return true

func _connection(to) -> void:
	pass

################################################################################
# talk to puredata
################################################################################

func create_connection(from_object_idx, from_slot_idx, to_object_idx, to_object_slot_idx):
	send_message(["connect", from_object_idx, from_slot_idx, to_object_idx, to_object_slot_idx])
	
func send_disconnect(from_object_idx, from_slot_idx, to_object_idx, to_object_slot_idx):
	send_message(["disconnect", from_object_idx, from_slot_idx, to_object_idx, to_object_slot_idx])

func send_message(args):
	if not supress_messages:
		PureData.send_message(canvas, args)

func save() -> void:
	
	#patch_file_handle_.close()
	print("saving %s" % canvas)

	var f := FileAccess.open(patch_path, FileAccess.WRITE)
	if not f:
		push_error("could not open file to save")

	f.store_string(serialize_(get_children()))

	f.close()

func try_add_child_(cable) -> void:
	if not cable.get_parent():
		add_child(cable)

func super_save_() -> void:
	PureData.send_message(canvas, ["menusave"])
	PureData.send_message("pd-xxx.pd", ["menusave"])
