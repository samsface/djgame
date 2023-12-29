extends Control
class_name PDSpecial

var parent : 
	set(value):
		pass
	get:
		return get_parent().get_parent().get_parent().get_parent()

func get_id_() -> String:
	var id := []
	
	var p = get_parent()
	while p:
		if p is PDNode:
			id.push_front(p.index)
		elif p is PDPatch:
			id.push_front("$1")
		p = p.get_parent()

	return '/'.join(id)

func get_receiver_id_() -> String:
	return '/r/' + get_id_()

func get_sender_id_() -> String:
	return '/s/' + get_id_()

func _connection(to:PDSlot):
	pass

func add_ghost_rs_() -> void:
	if not parent.canvas:
		return

	parent.send_message_(["obj", str(parent.position.x), str(parent.position.y - 15), "r", '/r/%s/%s' % ["$1", parent.index]])
	var r_id = parent.canvas.object_count_
	parent.canvas.object_count_ += 1

	parent.send_message_(["obj", str(parent.position.x), str(parent.position.y + 15), "s", '/s/%s/%s' % ["$1", parent.index]])
	var s_id = parent.canvas.object_count_
	parent.canvas.object_count_ += 1

	parent.send_message_(["connect", str(r_id), "0", str(parent.index), "0"])
	parent.send_message_(["connect", str(parent.index), "0", str(s_id), "0"])

func _pd_init() -> void:
	pass
