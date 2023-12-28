extends Control
class_name PDPatch

@export var root := false

enum Mode {
	none,
	selecting,
	dragging,
	connecting,
	searching,
	editing,
	resizing
}

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

var mode := Mode.none

func _ready() -> void:
	pass

func _input(event: InputEvent):
	if Input.is_action_just_pressed("save"):
		save()
	
	if mode >= Mode.connecting:
		return
		
	if Input.is_action_just_pressed("expand"):
		expand_()
		return
		
	if Input.is_action_just_pressed("rotate"):
		rotate_()
		return

	if Input.is_action_just_pressed("ui_down"):
		open_patch_in_new_window_()
	
	if Input.is_action_just_pressed("ui_cancel"):
		SelectionBus.clear_selection()
		
	if Input.is_action_just_pressed("select_all"):
		SelectionBus.clear_selection()
		for node in get_children():
			if "selectable" in node:
				SelectionBus.add_to_selection(node)
	
	if Input.is_action_just_pressed("delete"):
		delete_()
	if Input.is_action_just_pressed("redo"):
		undo_.redo()

	elif Input.is_action_just_pressed("undo"):
		undo_.undo()

	if Input.is_action_just_pressed("click"):
		if SelectionBus.selection_.size() <= 1:
			if SelectionBus.hovering:
				SelectionBus.change_selection(SelectionBus.hovering)

		if not SelectionBus.hovering:
			print("selecting")
			mode = Mode.selecting
			drag_selection_box_ = preload("res://widgets/selection_box/selection_box.tscn").instantiate()
			add_child(drag_selection_box_)
			drag_selection_box_.global_position = get_global_mouse_position()

		initial_click_position_ = get_global_mouse_position()
			
	elif Input.is_action_just_released("click"):
		if mode == Mode.selecting:
			mode = Mode.none
		elif mode == Mode.dragging:
			drag_end_()
		else:
			if SelectionBus.selection_.size() > 1:
				if SelectionBus.hovering:
					SelectionBus.change_selection(SelectionBus.hovering)

	elif Input.is_action_pressed("click"):
		if mode == Mode.selecting:
			pass
		else:
			drag_live_action_()

	if Input.is_action_just_pressed("search"):
		var x = preload("res://widgets/search/search.tscn").instantiate()
		x.position = get_global_mouse_position()
		x.end.connect(search_end_)
		add_child(x)

		mode = Mode.searching
		get_viewport().set_input_as_handled()

func get_connected_cables_(node:PDNode)-> Array:
	var res := []
	for object in get_children():
		if not object is PDNode:
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
	viewer.add(PureData.files["pd-square.pd"])
	var window := Window.new()
	window.size = get_viewport().size
	window.add_child(viewer)
	window.close_requested.connect(window.queue_free)
	get_tree().root.add_child(window)

################################################################################
# searching for stuff
################################################################################

func search_end_(search_text:String) -> void:
	mode = Mode.none

	if not search_text:
		return

	add_node_(search_text)

################################################################################
# deleting stuff
################################################################################

func delete_() -> void:
	var objects_to_delete = SelectionBus.selection_.duplicate()
	var cables_to_delete := []
	for object in objects_to_delete:
		if object is PDNode:
			cables_to_delete += get_connected_cables_(object)

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
# dragging
################################################################################

func drag_begin_() -> void:
	if SelectionBus.is_empty():
		return
	
	mode = Mode.dragging
	undo_.create_action("drag")
	
	var positions := []
	for node in SelectionBus.selection_:
		positions.push_back(node.position)

	undo_.add_undo_method(drag_action_.bind(SelectionBus.selection_.duplicate(), positions))

func drag_live_action_() -> void:
	if mode != Mode.dragging:
		if get_global_mouse_position().distance_to(initial_click_position_) > drag_threshold_:
			drag_begin_()
	
	if mode == Mode.dragging:
		for node in SelectionBus.selection_:
			node._drag(get_global_mouse_position())

func drag_action_(selection:Array, positions:Array) -> void:
	for i in selection.size():
		selection[i].position = positions[i]

func drag_end_() -> void:
	mode == Mode.none
	
	for node in SelectionBus.selection_:
		node._drag_end()
	
	var positions := []
	for node in SelectionBus.selection_:
		positions.push_back(node.position)

	undo_.add_do_method(drag_action_.bind(SelectionBus.selection_.duplicate(), positions))
	
	undo_.commit_action()

################################################################################
# random node tricks
################################################################################

func rotate_() -> void:
	for node in get_children():
		node.position = node.position.rotated(deg_to_rad(-90))

func expand_() -> void:
	for node in get_children():
		node.position = node.position * 2.0

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

	node.connection_clicked.connect(connection_clicked_)
	node.title_changed.connect(title_changed_.bind(node))
	node.begin_edit_text.connect(begin_edit_text_.bind(node))
	node.end_edit_text.connect(end_edit_text_.bind(node))
	node.begin_resize.connect(begin_resize_.bind(node))
	node.end_resize.connect(end_resize_.bind(node))

	return node

################################################################################
# adding connections
################################################################################

func find_node_by_object_id(id:int) -> Node:
	for node in get_children():
		if node is PDNode:
			if node.index == id:
				return node
	
	return null

func add_connection_(from_object:int, outlet:int, to_object:int, inlet:int) -> void:
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

	var cable = preload("cable.tscn").instantiate()
	cable.from = outlet_node
	cable.to = inlet_node
	add_child(cable)
	#cable.global_position = Vector2.ZERO
	cable.call_connect()

var cable_
func connection_clicked_(connection) -> void:
	if mode == Mode.selecting:
		drag_selection_box_.queue_free()
		drag_selection_box_ = null

	mode = Mode.connecting
	
	cable_ = preload("cable.tscn").instantiate()
	add_child(cable_)
	cable_.creating = true
	cable_.from = connection
	#cable_.global_position = Vector2.ZERO
	
	cable_.tree_exited.connect(connection_canceled_)
	cable_.connection.connect(connection_made_)

func connection_canceled_() -> void:
	mode = Mode.none

func connection_made_() -> void:
	mode = Mode.none
	
	undo_.create_action("connection")
	undo_.add_do_reference(cable_)
	undo_.add_do_method(connection_do_.bind(cable_))
	undo_.add_undo_method(remove_child.bind(cable_))
	undo_.commit_action()
	
func connection_do_(cable:PDCable) -> void:
	if not cable.get_parent():
		add_child(cable)

################################################################################
# resizing nodes
################################################################################

func begin_resize_(node) -> void:
	print("begin_resize_")
	if mode == Mode.selecting:
		drag_selection_box_.queue_free()
		drag_selection_box_ = null

	mode = Mode.resizing

func end_resize_(node:PDNode) -> void:
	mode = Mode.none

################################################################################
# updating node type
################################################################################

func begin_edit_text_(node) -> void:
	mode = Mode.editing

func end_edit_text_(node) -> void:
	mode = Mode.none

func title_changed_(next_text:String, node:PDNode) -> void:
	undo_.create_action("update")
	
	undo_.add_do_method(clear_connections_.bind(node))
	undo_.add_do_method(node.update.bind(next_text))
	undo_.add_do_method(add_connections_.bind(node))

	undo_.add_undo_method(clear_connections_.bind(node))
	undo_.add_undo_method(node.update.bind(node.text))
	undo_.add_undo_method(add_connections_.bind(node))

	undo_.commit_action()

func clear_connections_(node:PDNode) -> void:
	for cable in get_connected_cables_(node):
		cable.call_disconnect()

func add_connections_(node:PDNode) -> void:
	for cable in get_connected_cables_(node):
		cable.call_connect()

################################################################################

class IteratePackedStringArray:
	var packed_string_:PackedStringArray
	var i = 0
	
	func next():
		if i >= packed_string_.size():
			return null
		
		i += 1
		
		return packed_string_[i-1]
		
	func next_as_int():
		if i >= packed_string_.size():
			return null
		
		i += 1
		
		if packed_string_[i-1] == null:
			return 0

		return int(packed_string_[i-1])
		
	func join(join_string:String = " ") -> String:
		return join_string.join(packed_string_.slice(i-1))


class PDParseContext:
	var path:String
	
	func _init(file) -> void:
		path = file.substr(0, file.length() - file.get_file().length())

func get_obj_from_command(command:String) -> String:
	var a = command.split(' ')
	if a.size() < 5:
		return ""
	
	if a[1] != 'obj':
		return ""

	return a[4]

func parse_command(command:String, context:PDParseContext) -> void:
	if command.is_empty():
		return
	
	command = command.replace('\n', ' ')
	command = command.replace('  ', ' ')
	
	if command[0] == ' ':
		command = command.substr(1)


	var args = command.split(' ')

	var it = IteratePackedStringArray.new()
	it.packed_string_ = args
	
	var canvas = it.next()
	if canvas == null:
		push_error("canvas was null")
		return

	var message = it.next()
	if message == null:
		push_error("message was null: '%s'" % command)
		return

	if message == 'hsl' or message == 'obj' or message == 'floatatom' or message == 'msg' or message == 'coords':
		#var pos := Vector2.ZERO
		#pos.x = float(it.next())
		#pos.y = float(it.next())

		#var obj = it.next()
		#if obj == null:
		#	push_error("expected object")
		#	return

		#var node_model = NodeDb.db.get(obj)
		#if not node_model:
		#	var subpatch_path = context.path.path_join(obj + ".pd")
		#	if sub_patch_exists(subpatch_path):
		#		var subpatch = load("res://objects/patch.tscn").instantiate()
		#		subpatch.open(subpatch_path)
		#		#parse_sub_patch_file(subpatch_path, context)
		#	else:
		#		push_error("Unknown obj '%s'." % obj)
		#		return

		add_child(add_node__(it.join()))
	elif message == 'connect':
		var from = int(it.next())
		var outlet = int(it.next())
		var to = int(it.next())
		var inlet = int(it.next())
		add_connection_(from, outlet, to, inlet)

	#elif message == 'coords':
	#	execute_coords_command(' '.join(args.slice(1)))
  
func execute_coords_command(message) -> void:
	var n = add_node__(message)
	n.resizeable = true
	add_child(n)

func sub_patch_exists(path:String) -> bool:
	return FileAccess.file_exists(path)

func get_all_objects_(filter:String) -> Array:
	var res := []
	for node in get_children():
		if node is PDNode and node.text.contains(filter):
			res.push_back(node)
	
	return res

func open(path:String):
	patch_path = path
	prints("open_patch", path)
	var tmp_path = "res://junk/" + patch_path.get_file()
	
	#if not FileAccess.file_exists(tmp_path):
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	file.store_line("#N canvas 626 203 1354 1042 12;")
	file.close()

	var p = ProjectSettings.globalize_path(tmp_path)
	if not PureData.open_patch(p):
		push_error("couldn't open patch")

	canvas = "pd-" + tmp_path.get_file()
	
	var model := NodeDb.N.new()
	var context := PDParseContext.new(path)
	print("parsing %s" % path)
	var lines := FileAccess.get_file_as_string(path).split(';')
	for line in lines:
		parse_command(line, context)

	model.title = path.get_file().replace(".pd", "")
	model.specialized = load("res://objects/special/subpatch.tscn").duplicate()
	model.specialized.set_meta("path", tmp_path)
	model.instance = true
	model.visible_in_subpatch = true
	
	for i in get_all_objects_("inlet").size():
		model.inputs.push_back(NodeDb.C.new("input", "any"))
		
	for i in get_all_objects_("outlet").size():
		model.outputs.push_back(NodeDb.C.new("input", "any"))

	NodeDb.db[model.title] = model

	PureData.files[canvas] = self

	PureData.start_message(1)
	PureData.finish_message(canvas, "menusave")

	print("done parsing")

func _connection(to) -> void:
	pass

################################################################################
# talk to puredata
################################################################################

func create_connection(from_object_idx, from_slot_idx, to_object_idx, to_object_slot_idx):
	PureData.start_message(4)
	PureData.add_float(from_object_idx)
	PureData.add_float(from_slot_idx)
	PureData.add_float(to_object_idx)
	PureData.add_float(to_object_slot_idx)
	PureData.finish_message(canvas, "connect")

func send_disconnect(from_object_idx, from_slot_idx, to_object_idx, to_object_slot_idx):
	PureData.start_message(4)
	PureData.add_float(from_object_idx)
	PureData.add_float(from_slot_idx)
	PureData.add_float(to_object_idx)
	PureData.add_float(to_object_slot_idx)
	PureData.finish_message(canvas, "disconnect")

func save() -> void:
	print("saving %s" % canvas)
	PureData.start_message(0)
	#PureData.add_float(1)
	PureData.finish_message(canvas, "menusave")
