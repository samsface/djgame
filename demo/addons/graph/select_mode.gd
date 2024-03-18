extends GraphControlMode
class_name GraphControlSelectMode

var undo_ :
	set(value):
		pass
	get: return get_parent().undo_

var selection_:Array
var drag_selection_box_

static func test(input:InputEvent, selection:Array) -> bool:
	if not input is GraphControl.InputEventDrag:
		return false

	return true

func _init(selection:Array) -> void:
	selection_ = selection

func _ready() -> void:
	drag_selection_box_ = preload("res://addons/libpd/script/widgets/selection_box/selection_box.tscn").instantiate()
	add_child(drag_selection_box_)
	drag_selection_box_.global_position = get_global_mouse_position()
	drag_selection_box_.tree_exited.connect(queue_free)
