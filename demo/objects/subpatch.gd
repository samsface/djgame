extends MarginContainer

@export var patch_path:String

func _ready() -> void:
	var file = PureData.files["pd-" + patch_path.get_file()]
	
	for node in file.get_children():
		if node is PDNode:
			if node.text.begins_with('bng'):
				var n = node.duplicate()
				n.in_subpatch = true
				add_child(n)
			
func _connection(to) -> void:
	pass
