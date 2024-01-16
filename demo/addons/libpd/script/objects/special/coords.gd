extends PDSpecial

func find_host_() -> PDNode:
	var p := get_parent()
	while not p is PDNode:
		p = p.get_parent()
		
	if parent.in_subpatch:
		p = p.get_parent()
		while not p is PDNode:
			p = p.get_parent()
		
	return p
	
func get_subpatch():
	var p := get_parent()
	while p:
		if p is PDSubpatch:
			return p
		p = p.get_parent()
	
	return null

func _ready():
	await get_tree().process_frame
	
	parent.z_index -=1
	
	var it = PureData.IteratePackedStringArray.new(parent.text)
	var m = it.next()
	var x_from = it.next_as_int()
	var x_to = it.next_as_int()
	var y_from = it.next_as_int()
	var y_to = it.next_as_int()
	var width = it.next_as_int()
	var height = it.next_as_int()
	var graph_on_parent = it.next_as_int()
	var x = it.next_as_int()
	var y = it.next_as_int()
	
	var host = find_host_()
	
	host.custom_minimum_size = Vector2(width, height)

	if parent.in_subpatch:
		for node in get_subpatch().get_children():
			node.position -= Vector2(x, y)

		host.clip_contents = true
	else:
		host.position = Vector2(x, y)

func _pd_init() -> void:
	pass
