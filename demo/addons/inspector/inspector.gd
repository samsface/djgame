extends Control

var undo = UndoRedo.new()

var selection_:InspectorMultiSelection

var selection :
	set(value):
		selection = value
		selection_ = InspectorMultiSelection.new()
		
		if not selection:
			pass
		elif not value is Array:
			selection_.selection = [selection]
		else:
			selection_.selection = value
			
		invalidate_()

@export var virtual_properties:Node
@export var custom_rules:Array[Callable]
@export var hidden_properties:Array[StringName]
@export var visible_properties:Array[StringName]

var properties_to_poll_ := {}
var textures_:Array[Texture]
var property_updated_outside_of_inspector_:StringName

func invalidate_() -> void:
	for control in %Controls.get_children():
		control.queue_free()
		control.get_parent().remove_child(control)
	
	properties_to_poll_.clear()
	
	if virtual_properties:
		virtual_properties.node = null
	
	if not selection:
		return
	
	var properties := selection_.get_property_list()
	
	for property in properties:
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		
		if not visible_properties.is_empty():
			if not visible_properties.has(property.name):
				continue
			
		if property.name in hidden_properties:
			continue

		var control
		
		for rule in custom_rules:
			control = rule.call(property)
			if control:
				break

		if not control:
			match property.type:
				TYPE_OBJECT:
					if not property.class_name == "PackedScene":
						control = add_resource_control_(property)
						control.get_node("%Value").custom_rules = custom_rules
				TYPE_INT:
					if property.hint & PROPERTY_HINT_ENUM:
						control = add_enum_control_(property)
					else:
						control = add_int_control_(property)
				TYPE_FLOAT:
					control = add_float_control_(property)
				TYPE_VECTOR2:
					control = add_vector2_control_(property)
				TYPE_VECTOR3:
					control = add_vector3_control_(property)
				TYPE_TRANSFORM3D:
					control = add_transform_3d_control_(property)
				TYPE_STRING:
					if property.hint & PROPERTY_HINT_MULTILINE_TEXT:
						control = add_multiline_string_control_(property)
					else:
						control = add_string_control_(property)
				TYPE_STRING_NAME:
					control = add_string_control_(property)
				TYPE_NODE_PATH:
					control = add_string_control_(property)
				TYPE_BOOL:
					control = add_bool_control_(property)
		
		if not control:
			continue

		control.set_property(property)
		control.set_label(property.name)
		control.set_value(get_node_value_(property.name))
		properties_to_poll_[property.name] = [get_node_value_(property.name), control]
		control.value_changed.connect(_control_value_changed.bind(property.name))
		%Controls.add_child(control)

func _physics_process(delta):
	poll_node_properties_()

func register_textures(textures:Array[Texture]) -> void:
	textures_ = textures

func add_texture_picker_(property:Dictionary) -> Control:
	var control = load("res://addons/inspector/texture_picker.tscn").instantiate()
	control.items = textures_
	return control

func add_resource_control_(property:Dictionary) -> Control:
	var control = load("res://addons/inspector/resource_control.tscn").instantiate()
	return control

func add_enum_control_(property:Dictionary) -> Control:
	var control = preload("enum_control.tscn").instantiate()
	control.set_label(property.name)
	
	for e in property.hint_string.split(","):
		var name_value = e.split(":")
		if name_value.size() == 1:
			control.get_node("%Value").add_item(name_value[0])
		else:
			control.get_node("%Value").add_item(name_value[0], int(name_value[1]))

	return control

func add_float_control_(property:Dictionary) -> Control:
	var control = preload("int_control.tscn").instantiate()
	control.get_node("%Value").step = 0.01
	return control

func add_int_control_(property:Dictionary) -> Control:
	var control = preload("int_control.tscn").instantiate()
	return control

func add_vector2_control_(property:Dictionary) -> Control:
	var control = preload("vector2_control.tscn").instantiate()
	return control

func add_vector3_control_(property:Dictionary) -> Control:
	var control = preload("vector3_control.tscn").instantiate()
	return control

func add_transform_3d_control_(property:Dictionary) -> Control:
	var control = preload("transform_3d.tscn").instantiate()
	return control


func add_multiline_string_control_(property:Dictionary) -> Control:
	var control = preload("multiline_string_control.tscn").instantiate()
	return control

func add_string_control_(property:Dictionary) -> Control:
	var control = preload("string_control.tscn").instantiate()
	return control

func add_bool_control_(property:Dictionary) -> Control:
	var control = preload("bool_control.tscn").instantiate()
	return control

class Box:
	var x := 1

func _control_value_changed(new_value, property_name:String) -> void:
	if not selection:
		return
	
	if property_name == property_updated_outside_of_inspector_:
		return

	if properties_to_poll_[property_name][0] is NodePath:
		new_value = NodePath(new_value)

	if typeof(properties_to_poll_[property_name][0]) == typeof(new_value):
		if properties_to_poll_[property_name][0] == new_value:
			return

	undo.create_action("update " + property_name)

	var old_value = properties_to_poll_[property_name][0]
	
	var b := Box.new()

	undo.add_do_method(set_node_value_.bind(selection_, property_name, new_value, b))
	undo.add_undo_method(set_node_value_.bind(selection_, property_name, old_value))

	undo.commit_action()

func set_poll_value(property_name, new_value) -> void:
	properties_to_poll_[property_name][0] = new_value

# if you add type hints to the signature, the undo commit randomly won't call it
func set_node_value_(object, property_name, value, set_poll = null) -> void:
	var is_active_object = object == selection_
	
	if is_active_object and set_poll and set_poll.x > 0:
		set_poll.x = 0 
		properties_to_poll_[property_name][0] = value
	
	if object.has_property(property_name):
		object.set(property_name, value)
		if is_active_object and value is Object:
			properties_to_poll_[property_name][1].set_value(value)
	elif virtual_properties and property_name in virtual_properties:
		virtual_properties.set(property_name, value)
	else:
		push_error("UNKNOWN PROPERTY", property_name, object.name)

func get_node_value_(property_name:String):
	if selection_.has_property(property_name):
		return selection_.get(property_name)
	elif virtual_properties and property_name in virtual_properties:
		return virtual_properties.get(property_name)
	else:
		push_error("UNKNOWN PROPERTY", property_name)

func poll_node_properties_() -> void:
	if not selection:
		return
	
	for property_name in properties_to_poll_:
		var node_value = get_node_value_(property_name)
	
		if (typeof(node_value) != typeof(properties_to_poll_[property_name][0])) or (node_value != properties_to_poll_[property_name][0]):
			properties_to_poll_[property_name][0] = node_value
			property_updated_outside_of_inspector_ = property_name
			properties_to_poll_[property_name][1].set_value(node_value)
			property_updated_outside_of_inspector_ = StringName()

func copy_all_possible_property_values(from:Node, to:Node) -> void:
	for property in to.get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue

		if property.name in from:
			to.set(property.name, from.get(property.name))

func add_custom_control(control:Control) -> void:
	%Controls.add_child(control)

func scene_to_dict(node:Node):
	var res := {} 

	for property in node.get_property_list():
		if not property.name in visible_properties:
			continue

		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue

		res[property.name] = node.get(property.name) 

	res["scene_file_path"] = node.scene_file_path

	return res
	
func scene_from_dict(dict:Dictionary) -> Object:
	if "scene_file_path" in dict:
		var scene = load(dict.scene_file_path).instantiate()
		
		for key in dict:
			scene.set(key, dict[key])

		return scene
	
	return null
