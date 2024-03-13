extends Control

var undo = UndoRedo.new()

@export var node:Node :
	set(value):
		if node != value:
			node = value
			invalidate_()
		
@export var include_list:Array[String] 
@export var virtual_properties:Node

var properties_to_poll_ := {}

func invalidate_() -> void:
	for control in %Controls.get_children():
		control.queue_free()
		control.get_parent().remove_child(control)
	
	properties_to_poll_.clear()
	
	if virtual_properties:
		virtual_properties.node = null
	
	if not node:
		return
	
	var properties := node.get_property_list()
	
	if virtual_properties:
		virtual_properties.node = node
		properties = virtual_properties.get_property_list() + properties

	for property in properties:
		if property.usage & PROPERTY_USAGE_EDITOR == 0:
			continue

		if not (property.name in include_list):
			continue

		var control

		match property.type:
			TYPE_INT:
				if property.hint & PROPERTY_HINT_ENUM:
					control = add_enum_control_(property)
				else:
					control = add_int_control_(property)
			TYPE_FLOAT:
				control = add_float_control_(property)
			TYPE_STRING:
				control = add_string_control_(property)
			TYPE_STRING_NAME:
				control = add_string_control_(property)
			TYPE_BOOL:
				control = add_bool_control_(property)
		
		if not control:
			continue

		control.get_node("Label").text = property.name
		control.value = get_node_value_(property.name)
		properties_to_poll_[property.name] = [get_node_value_(property.name), control]
		control.value_changed.connect(_control_value_changed.bind(property.name))
		%Controls.add_child(control)

func _physics_process(delta):
	poll_node_properties_()

func add_enum_control_(property:Dictionary) -> Control:
	var control = preload("enum_control.tscn").instantiate()
	control.get_node("Label").text = property.name
	
	for e in property.hint_string.split(","):
		var name_value = e.split(":")
		if name_value.size() == 1:
			control.get_node("Value").add_item(name_value[0])
		else:
			control.get_node("Value").add_item(name_value[0], int(name_value[1]))

	return control

func add_float_control_(property:Dictionary) -> Control:
	var control = preload("int_control.tscn").instantiate()
	control.get_node("Value").step = 0.01
	return control

func add_int_control_(property:Dictionary) -> Control:
	var control = preload("int_control.tscn").instantiate()
	return control

func add_string_control_(property:Dictionary) -> Control:
	var control = preload("string_control.tscn").instantiate()
	return control

func add_bool_control_(property:Dictionary) -> Control:
	var control = preload("bool_control.tscn").instantiate()
	return control

func _control_value_changed(new_value, property_name:String) -> void:
	if not node:
		return
	
	if properties_to_poll_[property_name][0] == new_value:
		return

	undo.create_action("update " + property_name)

	var old_value = properties_to_poll_[property_name][0]

	undo.add_do_method(set_node_value_.bind(property_name, new_value, true))
	undo.add_undo_method(set_node_value_.bind(property_name, old_value))

	undo.commit_action()

func set_poll_value(property_name, new_value) -> void:
	properties_to_poll_[property_name][0] = new_value

func set_node_value_(property_name:String, value, set_poll := false) -> void:
	if set_poll:
		properties_to_poll_[property_name][0] = value
	
	if property_name in node:
		node.set(property_name, value)
	elif virtual_properties and property_name in virtual_properties:
		virtual_properties.set(property_name, value)
	else:
		push_error("UNKNOWN PROPERTY", property_name, node.name)

func get_node_value_(property_name:String):
	if property_name in node:
		return node.get(property_name)
	elif virtual_properties and property_name in virtual_properties:
		return virtual_properties.get(property_name)
	else:
		push_error("UNKNOWN PROPERTY", property_name, node.name)

func poll_node_properties_() -> void:
	if not node:
		return
	
	for property_name in properties_to_poll_:
		var node_value = get_node_value_(property_name)
		
		if node_value != properties_to_poll_[property_name][0]:
			properties_to_poll_[property_name][0] = node_value
			properties_to_poll_[property_name][1].value = node_value

func copy_all_possible_property_values(from:Node, to:Node) -> void:
	for property in to.get_property_list():
		if property.usage & PROPERTY_USAGE_EDITOR == 0:
			continue
			
		if not (property.name in include_list):
			continue

		if property.name in from:
			to.set(property.name, from.get(property.name))

func to_dict(node_to_dict:Node) -> Dictionary:
	var current_node = node

	var res := {}

	node = node_to_dict
	
	for property_name in properties_to_poll_:
		res[property_name] = var_to_str(get_node_value_(property_name))

	node = current_node
	
	return res
