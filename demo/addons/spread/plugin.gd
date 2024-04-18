@tool
extends EditorPlugin

var slider_:HSlider

func _ready():
	slider_ = HSlider.new()
	slider_.custom_minimum_size.x = 100
	slider_.max_value = 1.0
	slider_.step = 0.0
	slider_.value_changed.connect(_slide_value_changed)

func _slide_value_changed(value:float) -> void:
	spread(get_editor_interface().get_selection().get_selected_nodes(), value)

func sort_nodes_by_tree_index_(array:Array) -> Array:
	array.sort_custom(func(a, b): return a.get_index() > b.get_index())
	return array

func spread(nodes, seperate_distance:float) -> void:
	nodes = sort_nodes_by_tree_index_(nodes)

	for i in nodes.size():
		var node = nodes[i]
		node.position.z = seperate_distance * i * 0.1
	
	var center_offset = (nodes.front().position.z - nodes.back().position.z) * 0.5
	
	for i in nodes.size():
		var node = nodes[i]
		node.position.z += center_offset

func _handles(object) -> bool:
	if object.get_class() == "MultiNodeEdit":
		var can_handle = true;
		for node in get_editor_interface().get_selection().get_selected_nodes():
			if not node is Node3D:
				can_handle = false;
				break;
		show(can_handle)
		return can_handle;
	
	show(false)
	return false

func _edit(object) -> void:
	print("adding")

func show(value:bool) -> void:
	if value:
		if not slider_.get_parent():
			add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, slider_)
	else:
		if slider_.get_parent():
			remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, slider_)
