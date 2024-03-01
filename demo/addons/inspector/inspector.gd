extends MarginContainer

var undo = UndoRedo.new()

@export var node:Node :
	set(value):
		if node != value:
			node = value
			invalidate_()
		
@export var include_list:Array[String] 

var properties_to_poll_ := {}

func invalidate_() -> void:
	for control in %Controls.get_children():
		control.queue_free()
		control.get_parent().remove_child(control)
	
	properties_to_poll_.clear()
	
	if not node:
		return
	
	var properties := node.get_property_list()

	for property in properties:
		if property.usage & PROPERTY_USAGE_EDITOR == 0:
			continue
		
		if not include_list.is_empty():
			if property.name not in include_list:
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
		
		if not control:
			continue
		
		control.get_node("Label").text = property.name
		control.value = node.get(property.name)
		properties_to_poll_[property.name] = [node.get(property.name), control]
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

func _control_value_changed(new_value, property_name:String) -> void:
	if not node:
		return
	
	if properties_to_poll_[property_name][0] == new_value:
		return

	undo.create_action("update " + property_name)

	var old_value = properties_to_poll_[property_name][0]

	undo.add_do_method(func():
		properties_to_poll_[property_name][0] = new_value
		node.set(property_name, new_value)
	)
	undo.add_undo_method(func():
		node.set(property_name, old_value)
	)

	undo.commit_action()

func poll_node_properties_() -> void:
	if not node:
		return
	
	for property in properties_to_poll_:
		if node.get(property) != properties_to_poll_[property][0]:
			properties_to_poll_[property][0] = node.get(property)
			properties_to_poll_[property][1].value = node.get(property)
