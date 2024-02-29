extends Control

var node_path:NodePath
var track_name:Node
var queue := {}

func serialize() -> Dictionary:
	var res := { 
		"name": str(node_path),
		"notes": []
	}

	for note in get_children():
		res.notes.push_back({
			type = note.type,
			time = note.time,
			length = note.length,
			from_value = note.value,
			value = note.value
		})

	return res
	
func invalidate_queue() -> void:
	queue.clear()

	for node in get_children():
		queue[node.time] = node
