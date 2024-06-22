extends HBoxContainer

var root_node:Node

@export var node_path:NodePath : 
	set(v):
		node_path = v
		invalidate_()

@export_multiline var condition_ex:String : 
	set(v):
		condition_ex = v
		invalidate_()

func pretty_name(np:NodePath):
	var split = str(np).split("/")

	if split.size() > 1:
		return split[0] + "/" + split[split.size() - 1]
	
	return str(np)
	

func invalidate_() -> void:
	$Value.text = pretty_name(node_path)
	
	if try_get_node() == null:
		modulate = Color.RED
	else:
		modulate = Color.WHITE
	
	if condition_ex.is_empty():
		$Condition.visible = false
	else:
		$Condition.visible = true

func try_get_node() -> Node:
	if not root_node:
		return null
	
	if not node_path:
		return root_node
		
	return root_node.get_node_or_null(node_path)
