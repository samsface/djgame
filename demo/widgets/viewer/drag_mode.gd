extends Mode
class_name DragMode

var undo_ :
	set(value):
		pass
	get: return get_parent().undo_

var selection_:Array

static func test(input:InputEvent, selection:Array) -> bool:
	if input is PDPatch.InputEventDrag and not selection.is_empty():
		return true
	
	return false

func _init(selection:Array) -> void:
	selection_ = selection

func get_positions_(nodes) -> Array:
	var positions := []
	for node in nodes:
		positions.push_back(node.position)
	
	return positions

func _ready() -> void:
	undo_.create_action("drag")

	undo_.add_undo_method(DragMode.drag_action_.bind(selection_.duplicate(), get_positions_(selection_)))

func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		for node in selection_:
			node._drag(get_global_mouse_position())
			
	if event.is_action_released("click"):
		queue_free()

static func drag_action_(selection:Array, positions:Array) -> void:
	for i in selection.size():
		selection[i].position = positions[i]

func _exit_tree():
	for node in selection_:
		node._drag_end()

	undo_.add_do_method(DragMode.drag_action_.bind(selection_.duplicate(), get_positions_(selection_)))
	
	undo_.commit_action()
