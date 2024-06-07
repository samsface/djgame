extends Control
class_name InspectorControl

signal value_changed

var property_:Dictionary

func set_property(property:Dictionary) -> void:
	property_ = property

func set_label(label:String) -> void:
	%Label.text = label.capitalize()

func set_value(value) -> void:
	pass

func get_inherited_classes_(classname:StringName) -> Array:
	var res := []
	var class_list := ProjectSettings.get_global_class_list()
	
	var base
	
	for item in class_list:
		if item.class == classname:
			base = item.base
			break
	
	for item in class_list:
		if item.base == base:
			res.push_back(item)
	
	return res
