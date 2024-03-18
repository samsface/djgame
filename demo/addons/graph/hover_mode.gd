extends GraphControlMode
class_name GraphControlHoverMode

var cursor_ :
	set(value):
		pass
	get: return get_parent().cursor_

func block() -> bool:
	return false

func remove_hovering_slot_() -> void:
	if SelectionBus.hovering_slot:
		if SelectionBus.hovering_slot.is_inside_tree():
			SelectionBus.hovering_slot._mouse_exited()
		SelectionBus.hovering_slot = null

func _input(event:InputEvent) -> void:
	if cursor_.has_overlapping_areas():
		var slots = []
		for node in cursor_.get_overlapping_areas():
			slots += node.get_slots()
		
		var closet_slot = SelectionBus.find_closet_node(slots, get_global_mouse_position())
		
		if closet_slot != SelectionBus.hovering_slot:
			remove_hovering_slot_()
			SelectionBus.hovering_slot = closet_slot
			if closet_slot:
				closet_slot._mouse_entered()
	else:
		remove_hovering_slot_()

func _exit_tree() -> void:
	remove_hovering_slot_()
