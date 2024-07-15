extends GraphEdit

@export var connections:Array
@export var ops:Array[PackedScene]
@export var root_node:NodePath

var undo_ := UndoRedo.new()
var clipboard_ := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for connection in connections:
		connect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_undo"):
		undo_.undo()
	elif event.is_action_pressed("ui_redo"):
		undo_.redo()
	elif event.is_action_pressed("save"):
		save()
	elif event.is_action_pressed("ui_end"):
		for node in get_children():
			if node.selected:
				node.begin()

func _copy_nodes_request() -> void:
	
	clipboard_.clear()
	
	for child in get_children():
		if child.selected:
			clipboard_.push_back(child.duplicate())

func get_local_mouse_position_offset() -> Vector2:
	return to_local(get_local_mouse_position())

func to_local(p) -> Vector2:
	return (p + scroll_offset) / zoom

func _paste_nodes_request() -> void:
	if clipboard_.is_empty():
		return
	
	for child in get_children():
		if child.selected:
			child.selected = false

	var min_xy:Vector2 = clipboard_.front().position_offset
	for node in clipboard_:
		min_xy.x = min(node.position_offset.x, min_xy.x)
		min_xy.y = min(node.position_offset.y, min_xy.y)

	undo_.create_action("paste")

	for node in clipboard_:
		var n = node.duplicate()
		n.position_offset = n.position_offset - min_xy + get_local_mouse_position_offset()
		undo_.add_do_method(add_child.bind(n))
		undo_.add_do_method(n.set.bind("owner", self))
		undo_.add_do_reference(n)
		undo_.add_undo_method(remove_child.bind(n))

	undo_.commit_action()

func _connection_request(from_node, from_port: int, to_node, to_port: int) -> void:
	var from:GraphNode = get_node(str(from_node))
	var to:GraphNode = get_node(str(to_node))

	if is_node_connected(from_node, from_port, to_node, to_port):
		return

	undo_.create_action("connect")
	undo_.add_do_method(connect_node_.bind(from_node, from_port, to_node, to_port))
	undo_.add_undo_method(disconnect_node_.bind(from_node, from_port, to_node, to_port))
	undo_.commit_action()

func _connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2) -> void:
	undo_.create_action("new")
	var a := Node.new()
	var n = load(get_node(str(from_node)).scene_file_path).instantiate()
	n.name = str(randi())
	n.position_offset = to_local(release_position)
	undo_.add_do_method(add_child.bind(n))
	undo_.add_do_method(focus_first.bind(n))
	undo_.add_do_method(n.set.bind("owner", self))
	undo_.add_do_reference(n)
	undo_.add_do_method(connect_node_.bind(from_node, from_port, n, 0))
	undo_.add_undo_method(disconnect_node_.bind(from_node, from_port, n, 0))
	undo_.add_undo_method(remove_child.bind(n))
	undo_.commit_action()

func focus_first(n) -> void:
	n.get_child(0).grab_focus()

func connect_node_(from_node, from_port:int, to_node, to_port:int) -> bool:
	if from_node is Node:
		from_node = from_node.name
	if to_node is Node:
		to_node = to_node.name
	
	if is_node_connected(from_node, from_port, to_node, to_port):
		return false
		
	connect_node(from_node, from_port, to_node, to_port)

	return true

func disconnect_node_(from_node, from_port:int, to_node, to_port:int) -> bool:
	if from_node is Node:
		from_node = from_node.name
	if to_node is Node:
		to_node = to_node.name

	if not is_node_connected(from_node, from_port, to_node, to_port):
		return false
		
	disconnect_node(from_node, from_port, to_node, to_port)
	
	return true

func _disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	undo_.create_action("disconnect")
	undo_.add_do_method(disconnect_node.bind(from_node, from_port, to_node, to_port))
	undo_.add_undo_method(connect_node.bind(from_node, from_port, to_node, to_port))
	undo_.add_undo_method(force_connection_drag_end)
	undo_.commit_action()

func save() -> void:
	connections = get_connection_list()
	var a := PackedScene.new()
	a.pack(self)
	ResourceSaver.save(a, "res://junk/dialogs/test.tscn")

func _delete_nodes_request(node_names: Array[StringName]) -> void:
	undo_.create_action("delete")
	
	var connection_list = get_connection_list()
	
	var deleted_connections := []
	
	for node_name in node_names:
		for connection in connection_list:
			if connection.from_node == node_name or connection.to_node == node_name:
				deleted_connections.push_back(connection)
		
		var node = get_node(str(node_name))
		undo_.add_do_method(remove_child.bind(node))
		undo_.add_undo_method(add_child.bind(node))
		undo_.add_undo_reference(node)
		undo_.add_undo_method(func(): 
			for connection in deleted_connections:
				connect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port))
	undo_.commit_action()

func _popup_request(position: Vector2) -> void:
	var search := preload("res://addons/fuzzy_search/fuzzy_search_control.tscn").instantiate()

	for op in ops:
		var human_readable_name = (op as PackedScene).resource_path.get_file().capitalize().replace("Dialog Graph", "").replace("Op.tscn", "")
		search.data.push_back(human_readable_name)
		search.data_user.push_back(op)
	
	search.position = position
	search.found.connect(search_found.bind(search))
	search.cancel.connect(search.queue_free)
	add_child(search)

func search_found(result:String, user_data:Object, search_control:Control) -> void:
	search_control.queue_free()
	
	var new_op = user_data.instantiate()
	new_op.position_offset = to_local(search_control.position)
	add_child(new_op)

