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
