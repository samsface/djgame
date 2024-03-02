extends Object
class_name Dictializer

static func to_dict(object:Object, incluse_list := []) -> Dictionary:
	var res = {}
	
	var properties = object.get_property_list()

	for property in properties:
		if property.usage & PROPERTY_USAGE_EDITOR == 0:
			continue
		
		if property.name not in incluse_list:
			continue

		if property.type < TYPE_OBJECT:
			res[property.name] = var_to_str(object.get(property.name))
		else:
			push_error("NO SUPPORT FOR THAT TYPE")

	return res

static func from_dict(dict:Dictionary, object:Object) -> void:
	for key in dict:
		object.set(key, str_to_var(dict[key]))
