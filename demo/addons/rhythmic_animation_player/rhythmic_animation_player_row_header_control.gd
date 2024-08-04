extends HBoxContainer

signal node_path_changed

var root_node:Node

@export var type:int : 
	set(v):
		type = v

@export var node_path:NodePath : 
	set(v):
		node_path = v
		invalidate_()
		node_path_changed.emit()

@export_multiline var condition_ex:String : 
	set(v):
		condition_ex = v
		invalidate_()

func pretty_name(np:NodePath):
	var str = str(np)
	str = str.replace("%", "")

	var split = str(str).split("/")

	if split.size() > 1:
		return split[0] + "/" + split[split.size() - 1]
	
	return str(str)
	
func get_target_node_property_path() -> NodePath:
	var str := str(node_path)
	var search := str.find(":")
	if search != -1:
		return NodePath(str.substr(search))
	else:
		return NodePath()

func invalidate_() -> void:
	$Value.text = pretty_name(node_path)
	
	var node = try_get_node()
	if node == null:
		modulate = Color.RED
	else:
		var property_path := get_target_node_property_path()
		if property_path:
			if node.get_indexed(property_path) == null:
				modulate = Color.RED
			else:
				modulate =  hash_path_as_color_(node_path)
		else:
			modulate =  hash_path_as_color_(node_path)
	
	if condition_ex.is_empty():
		$Condition.visible = false
	else:
		$Condition.visible = true

# Function to get a random color based on a string
func get_color_from_string(s: String) -> Color:
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(s)

	var r = rng.randf_range(0.0, 1.0)
	var g = rng.randf_range(0.0, 1.0)
	var b = rng.randf_range(0.0, 1.0)

	return Color(r, g, b)
	
func hash_path_as_color_(path:NodePath) -> Color:
	if path.is_empty():
		return Color.RED

	return get_color_from_string(path.get_name(0))

func try_get_node() -> Node:
	if not root_node:
		return null
	
	if not node_path:
		return root_node
		
	return root_node.get_node_or_null(node_path)
