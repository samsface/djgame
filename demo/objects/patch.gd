extends Control
class_name PDPatch

signal done

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
var is_done := false

var patch_file_handle_ := PDPatchFile.new()
var cursor_:Area2D

var mode_

func _ready() -> void:
	cursor_ = preload("res://widgets/cursor/cursor.tscn").instantiate()
	add_child(cursor_)

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

	if event.is_action_pressed("save"):
		save()

	elif PlayMode.test(event, SelectionBus.selection_):
		enter_mode_(PlayMode.new())

	elif DragMode.test(event, SelectionBus.selection_):
		enter_mode_(DragMode.new(SelectionBus.selection_))

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
	#if mode == Mode.selecting:
	#	drag_selection_box_.queue_free()
	#	drag_selection_box_ = null

	#mode = Mode.resizing
	pass

func end_resize_(node:PDNode) -> void:
	#mode = Mode.none
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

func parse_command(command:String, context:PDParseContext) -> void:
	command = command.replace('\n', ' ')
	command = command.replace('  ', ' ')

	if command[0] == ' ':
		command = command.substr(1)

	if command.is_empty():
		return

	var args = command.split(' ')

	var it = PureData.IteratePackedStringArray.new()
	it.packed_string_ = args
	
	var canvas = it.next()
	if canvas == null:
		push_error("canvas was null")
		return

	var message = it.next()
	if message == null:
		push_error("message was null: '%s'" % command)
		return

	if message == 'connect':
		var from = int(it.next())
		var outlet = int(it.next())
		var to = int(it.next())
		var inlet = int(it.next())
		add_connection_(from, outlet, to, inlet)
	else:
		add_child(add_node__(it.join()))

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

	var cable = preload("res://objects/cable.tscn").instantiate()
	cable.from = outlet_node
	cable.to = inlet_node
	add_child(cable)
	#cable.global_position = Vector2.ZERO
	cable.call_connect()

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
	
	var context := PDParseContext.new(path)
	print("parsing %s" % path)
	PureData.supress_messages = true
	var lines := FileAccess.get_file_as_string(patch_path).split(';')
	for line in lines:
		parse_command(line, context)
	PureData.supress_messages = false

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

	is_done = true
	done.emit()
	
	#PureData.send_message(canvas, ["menusave"])

	print("done parsing")
	
	return true

func _connection(to) -> void:
	pass

################################################################################
# talk to puredata
################################################################################

func create_connection(from_object_idx, from_slot_idx, to_object_idx, to_object_slot_idx):
	PureData.send_message(canvas, ["connect", from_object_idx, from_slot_idx, to_object_idx, to_object_slot_idx])
	
func send_disconnect(from_object_idx, from_slot_idx, to_object_idx, to_object_slot_idx):
	PureData.send_message(canvas, ["disconnect", from_object_idx, from_slot_idx, to_object_idx, to_object_slot_idx])

func save() -> void:
	
	#patch_file_handle_.close()
	print("saving %s" % canvas)

	var f := FileAccess.open(patch_path, FileAccess.WRITE)
	if not f:
		push_error("could not open file to save")

	f.store_line("#N canvas 757 493 971 650 12;")

	var coords

	var rejigged_indexs := {}

	for node in get_children():
		if node is PDNode:
			if not node.visible:
				continue
			if node.text.begins_with("coords"):
				coords = node
			else:
				f.store_line("#X " + node.text + ";")
				rejigged_indexs[node] = rejigged_indexs.size()

	for node in get_children():
		if not node.visible:
			continue
		if node is PDCable:
			var from = rejigged_indexs[node.from.parent]
			var to = rejigged_indexs[node.to.parent]
			f.store_line("#X connect %s %s %s %s;" % [from, node.from.index, to, node.to.index])

	if coords:
		f.store_line("#X " + coords.text + ";")

	f.close()

func try_add_child_(cable) -> void:
	if not cable.get_parent():
		add_child(cable)

