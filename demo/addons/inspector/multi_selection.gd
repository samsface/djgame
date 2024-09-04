extends RefCounted
class_name InspectorMultiSelection

var selection:Array : 
	set(v):
		selection = v
		invalidate_property_list_()

var property_list_:Dictionary
var property_list__:Array[Dictionary]

func has_property(property_name:StringName) -> bool:
	return property_list_.has(property_name)

func hash_property_list_(property_list:Array[Dictionary]) -> Dictionary:
	var res := {}
	for property in property_list:
		res[property.name] = property

	return res

func intersection_(dict_a:Dictionary, dict_b:Dictionary) -> Dictionary:
	var res := {}
	for key in dict_a:
		if key in dict_b:
			res[key] = dict_a[key]
			Geometry2D
	return res

func invalidate_property_list_() -> void:
	property_list_.clear()
	property_list__.clear()
	
	if selection.is_empty():
		return
	
	property_list_ = hash_property_list_(selection[0].get_property_list())
	
	for object in selection:
		property_list_ = intersection_(property_list_, hash_property_list_(object.get_property_list()))
	
	property_list__ = Array(property_list_.values(), TYPE_DICTIONARY, "", null)

func _get_property_list() -> Array[Dictionary]:
	return property_list__

func get_int_(property_name) -> int:
	return selection.reduce(func(accum, object:Object): return object.get(property_name))

func _get(property_name:StringName):
	return selection[0].get(property_name)

func _set(property_name:StringName, property_value):
	for object in selection:
		object.set(property_name, property_value)
