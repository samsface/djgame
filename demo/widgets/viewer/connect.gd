extends Mode
class_name ConnectMode

var slot_
var candidate_slot_
var cable_
var adding_new_object_ := false

var undo_ :
	set(value):
		pass
	get: return get_parent().undo_

var cursor_ :
	set(value):
		pass
	get: return get_parent().cursor_

func _init(slot) -> void:
	slot_ = slot

func skip_(slot:PDSlot) -> bool:
	if slot.is_output == slot_.is_output:
		return true
		
	if slot.parent == slot_.parent:
		return true
	
	return false

func get_best_hovering_slot_() -> PDSlot:
	if cursor_.has_overlapping_areas():
		var slots = []
		for node in cursor_.get_overlapping_areas():
			slots += node.get_slots()

		return SelectionBus.find_closet_node_with_skip(
			slots, 
			get_global_mouse_position(),
			skip_)
	else:
		return null

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		_cancel()
		return

	if not adding_new_object_:
		if event is InputEventMouseMotion:
			var slot = get_best_hovering_slot_()
			if slot != candidate_slot_:
				if candidate_slot_:
					candidate_slot_._mouse_exited()
					candidate_slot_ = null
				
				candidate_slot_ = slot
				
				if candidate_slot_:
					slot._mouse_entered()

			if not cable_.from:
				cable_.fallback_from_position = get_global_mouse_position()
			if not cable_.to:
				cable_.fallback_to_position = get_global_mouse_position()

	if event.is_action_released("right_click"):
		connection_request_()

func _ready() -> void:
	cable_ = preload("res://objects/cable.tscn").instantiate()
	cable_.creating = true
	if slot_.is_output:
		cable_.from = slot_
		cable_.fallback_to_position = get_global_mouse_position()
	else:
		cable_.to = slot_
		cable_.fallback_from_position = get_global_mouse_position()

	get_parent().add_child(cable_)

	undo_.create_action("connection")
	undo_.add_do_reference(cable_)
	undo_.add_do_method(get_parent().try_add_child_.bind(cable_))
	undo_.add_undo_method(get_parent().remove_child.bind(cable_))

func connection_request_() -> void:
	if candidate_slot_:
		done_(candidate_slot_)
	else:
		adding_new_object_ = true

		var x = preload("res://widgets/search/search.tscn").instantiate()
		x.position = get_global_mouse_position()
		x.end.connect(connection_requests_new_object_search_end_)
		add_child(x)

func connection_requests_new_object_search_end_(text) -> void:
	if not text:
		_cancel()
		return

	var n = get_parent().add_node__(text)

	var best_slot = n.get_best_slot(cable_.creating_slot)
	if not best_slot:
		cable_.queue_free()
		n.queue_free()
		return

	get_parent().add_child(n)

	undo_.add_do_reference(n)
	undo_.add_do_method(get_parent().try_add_child_.bind(n))
	undo_.add_undo_method(get_parent().remove_child.bind(n))
	
	done_(best_slot)
	
	queue_free()

func done_(slot:PDSlot) -> void:
	undo_.commit_action()
	slot_._mouse_exited()
	cable_.connect_(slot)
	queue_free()

func _cancel() -> void:
	undo_.commit_action(false)
	slot_._mouse_exited()
	if cable_:
		cable_.queue_free()
	queue_free()
