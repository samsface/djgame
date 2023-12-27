extends Control
class_name PDPatch

@export var patch_path:String :
	set(value):
		patch_path = value

@export var root := false

var undo_ := UndoRedo.new()
var canvas:String
var lines := []
var drag_selection_box_
var drag_threshold_ := 0.5
var initial_click_position_ := Vector2.ZERO
var dragging_ := false
var selecting_ := false
var editing_text_ := false
var searching_ := false
var connecting_:Node = null
var object_count_ := 0
var x := false


func _ready() -> void:
	if not x:
		init()

func init() -> void:
	x = true
	open_patch_(patch_path)

func _input(event: InputEvent):
	if Input.is_action_just_pressed("save"):
		save()
	
	if searching_:
		return

	if editing_text_:
		return
		
	if connecting_:
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
			selecting_ = true
			drag_selection_box_ = preload("res://widgets/selection_box/selection_box.tscn").instantiate()
			add_child(drag_selection_box_)
			drag_selection_box_.global_position = get_global_mouse_position()

		initial_click_position_ = get_global_mouse_position()
			
	elif Input.is_action_just_released("click"):
		if selecting_:
			selecting_ = false
		elif dragging_:
			drag_end_()
		else:
			if SelectionBus.selection_.size() > 1:
				if SelectionBus.hovering:
					SelectionBus.change_selection(SelectionBus.hovering)

	elif Input.is_action_pressed("click"):
		if selecting_:
			pass
		else:
			drag_live_action_()

	if Input.is_action_just_pressed("search"):
		var x = preload("res://widgets/search/search.tscn").instantiate()
		add_child(x)
		x.global_position = get_global_mouse_position()
		x.end.connect(search_end_.bind(x.global_position))
		searching_ = true
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
	var window := Window.new()
	window.size = get_viewport().size
	var p = load("res://viewer2.tscn").instantiate()
	p.get_node("SubViewport/MarginContainer").add_child(PureData.files["pd-subpatch.pd"])
	
	get_tree().root.add_child(window)
	window.add_child(p)

################################################################################
# searching for stuff
################################################################################

func search_end_(search_text:String, pos:Vector2) -> void:
	searching_ = false

	if not search_text:
		return

	add_node_(search_text, pos)

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
	
	dragging_ = true
	undo_.create_action("drag")
	
	var positions := []
	for node in SelectionBus.selection_:
		positions.push_back(node.position)

	undo_.add_undo_method(drag_action_.bind(SelectionBus.selection_.duplicate(), positions))

func drag_live_action_() -> void:
	if not dragging_:
		if get_global_mouse_position().distance_to(initial_click_position_) > drag_threshold_:
			drag_begin_()
	
	if dragging_:
		for node in SelectionBus.selection_:
			node._drag(get_global_mouse_position())

func drag_action_(selection:Array, positions:Array) -> void:
	for i in selection.size():
		selection[i].position = positions[i]

func drag_end_() -> void:
	dragging_ = false
	
	for node in SelectionBus.selection_:
		node._drag_end()
	
	var positions := []
	for node in SelectionBus.selection_:
		positions.push_back(node.position)

	undo_.add_do_method(drag_action_.bind(SelectionBus.selection_.duplicate(), positions))
	
	undo_.commit_action()

################################################################################
# adding nodes
################################################################################

func add_node_(node_name:String, pos:Vector2):
	var n = add_node__(node_name, pos)

	undo_.create_action("add_node")
	undo_.add_do_method(add_child.bind(n))
	undo_.add_do_reference(n)
	undo_.add_undo_method(remove_child.bind(n))
	undo_.commit_action()

func add_node__(node_name:String, pos:Vector2):
	var node = preload("res://objects/graph_node.tscn").instantiate()
	node.name = node_name
	node.canvas = self
	node.position = pos
	node.text = node_name

	node.connection_clicked.connect(connection_clicked_)
	node.title_changed.connect(title_changed_.bind(node))
	node.begin_edit_text.connect(begin_edit_text_.bind(node))
	node.end_edit_text.connect(end_edit_text_.bind(node))

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
	cable.call_connect()

func connection_clicked_(connection) -> void:
	if connecting_:
		var cable = preload("cable.tscn").instantiate()
		cable.from = connecting_.from
		cable.to = connection

		undo_.create_action("connection")
		undo_.add_do_reference(cable)
		undo_.add_do_method(add_child.bind(cable))
		undo_.add_undo_method(remove_child.bind(cable))
		undo_.commit_action()
		SelectionBus.remove_from_all(connecting_)
		connecting_.queue_free()
		remove_child(connecting_)

		connecting_ = null
		return

	connecting_ = preload("cable.tscn").instantiate()
	connecting_.creating = true
	connecting_.from = connection
	
	connecting_.tree_exited.connect(func(): SelectionBus.remove_from_all(connecting_); connecting_ = null)

	add_child(connecting_)
	connecting_.global_position = Vector2.ZERO
	SelectionBus.change_selection(connecting_)

################################################################################
# updating node type
################################################################################

func begin_edit_text_(node) -> void:
	editing_text_ = true

func end_edit_text_(node) -> void:
	editing_text_ = false

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

	if message == 'obj':
		var pos := Vector2.ZERO
		pos.x = float(it.next())
		pos.y = float(it.next())

		var obj = it.next()
		if obj == null:
			push_error("expected object")
			return

		var node_model = NodeDb.db.get(obj)
		if not node_model:
			var subpatch_path = context.path.path_join(obj + ".pd")
			if sub_patch_exists(subpatch_path):
				parse_sub_patch_file(subpatch_path, context)
			else:
				push_error("Unknown obj '%s'." % obj)
				return

		add_child(add_node__(it.join(), pos))

	elif message == 'connect':
		var from = int(it.next())
		var outlet = int(it.next())
		var to = int(it.next())
		var inlet = int(it.next())
		add_connection_(from, outlet, to, inlet)

	elif message == 'coords':
		execute_coords_command(
			it.next_as_int(),
			it.next_as_int(),
			it.next_as_int(),
			it.next_as_int(),
			it.next_as_int(),
			it.next_as_int(),
			it.next_as_int(),
			it.next_as_int(),
			it.next_as_int())

func execute_coords_command(x_from, x_to, y_from, y_to, width, height, graph_on_parent, x, y) -> void:
	return
	if graph_on_parent == 0:
		return
	
	custom_minimum_size = Vector2(width, height)
	clip_contents = true
	
	for node in get_children():
		node.position -= Vector2(x, y)

	PureData.start_message(9)
	PureData.add_float(x_from)
	PureData.add_float(x_to)
	PureData.add_float(y_from)
	PureData.add_float(y_to)
	PureData.add_float(width)
	PureData.add_float(height)
	PureData.add_float(graph_on_parent)
	PureData.add_float(x)
	PureData.add_float(y)
	PureData.finish_message(canvas, "coords")

func sub_patch_exists(path:String) -> bool:
	return FileAccess.file_exists(path)

func parse_sub_patch_file(path:String, context):
	var model := NodeDb.N.new()
	model.title = path.get_file().replace(".pd", "")

	print("parse_sub_patch_file %s" % path)
	var lines := FileAccess.get_file_as_string(path).split(';')
	for line in lines:
		var message = get_obj_from_command(line)
		if not message:
			continue

		var node_model = NodeDb.db.get(message)
		if not node_model:
			continue

		if node_model.title == "inlet":
			var c = NodeDb.C.new("arg", "any")
			model.inputs.push_back(c)
		elif node_model.title == "outlet":
			var c = NodeDb.C.new("arg", "any")
			model.outputs.push_back(c)
	
	model.inputs.push_back(NodeDb.C.new("namespace", "string"))
	
	model.specialized = load("res://objects/special/subpatch.tscn")
	model.specialized.set_meta("path", path)
	model.instance = true


	NodeDb.db[model.title] = model

	var p = load("res://objects/patch.tscn").instantiate()
	p.patch_path = "res://addons/libpd/subpatch.pd"
	p.init()
	p.save()
	
	
	PureData.start_message(1)
	PureData.finish_message("pd-subpatch.pd", "menusave")

	print("done parse_sub_patch_file")

func open_patch_(path:String):
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
	
	var context := PDParseContext.new(path)
	print("parsing %s" % path)
	var lines := FileAccess.get_file_as_string(path).split(';')
	for line in lines:
		parse_command(line, context)

	parse_command("#X obj 2000 2000 inlet", context)

	PureData.files[canvas] = self

	print("done parsing")

func _connection(to) -> void:
	pass

################################################################################
# talk to puredata
################################################################################

func create_obj(message:String, pos:Vector2 = Vector2.ZERO) -> Array:
	message = message.replace('\n', ' ')
	var args = message.split(' ')
	
	var obj = NodeDb.db.get(args[0])
	if not obj:
		return []

	args += obj.default_args.slice(args.size())

	if obj.title == 'bang':
		var ns := "/$1"
		if root:
			ns = ""

		args[0] = "bng"
		var rid = str(object_count_)
		args[5] = '/s%s/%s' % [ns, rid]
		args[6] = '/r%s/%s' % [ns, rid]
	elif obj.instance:
		args.push_back(str(object_count_))

	#if args[0] == "bang":
	#	args[0] = "bng"

	PureData.start_message(args.size() + 2)

	PureData.add_float(pos.x)
	PureData.add_float(pos.y)

	for arg in args:
		if PureData.regex.search(arg):
			PureData.add_float(float(arg))
		else:
			PureData.add_symbol(arg)

	if args[0] == "floatatom":
		PureData.finish_message(canvas, "floatatom")
	else:
		PureData.finish_message(canvas, "obj")

	if obj.instance:
		pass
		
	object_count_ += 1

	return [object_count_ - 1, ' '.join(args)]

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

var hack_ := {}

func save() -> void:


	PureData.start_message(1)
	PureData.add_float(1)
	PureData.finish_message(canvas, "menusave")

	
	#PureData.start_message(1)
	#PureData.finish_message("pd-subpatch.pd", "menusave")
	
	
