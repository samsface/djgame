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

func invalidate_() -> void:
	$Value.text = str(node_path)
	
	if condition_ex.is_empty():
		$Condition.visible = false
	else:
		$Condition.visible = true

func try_get_node() -> Node:
	if not root_node:
		return null
		
	return root_node.get_node_or_null(node_path)
