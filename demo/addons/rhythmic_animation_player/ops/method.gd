extends RythmicAnimationPlayerControlItem

@export var method:StringName :
	set(v):
		method = v
		$Label.text = method

func parse_args_(object:Object, method_name:StringName, args:PackedStringArray) -> Array:
	var res := []
	
	if object.has_method(method_name):
		for method in object.get_method_list():
			if method.name == method_name:
				for i in method.args.size():
					if (i+1) >= args.size():
						break
					
					if method.args[i].type == TYPE_INT:
						res.push_back(int(args[i+1]))
					elif method.args[i].type == TYPE_FLOAT:
						res.push_back(float(args[i+1]))
					else:
						res.push_back(args[i+1])

	return res

func begin() -> void:
	var node = get_target_node()

	var method_args_generic = method.split(" ")
	var method_name = method_args_generic[0]

	var args = parse_args_(node, method_name, method_args_generic)
	node.callv(method_name, args)
