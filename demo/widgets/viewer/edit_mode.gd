extends Mode
class_name EditMode

var node_

var undo_ :
	set(value):
		pass
	get: return get_parent().undo_

static func test(input:InputEvent, selection:Array) -> bool:
	if selection.is_empty():
		return false

	if input is InputEventMouseButton:
		if input.double_click:
			return true
	return false

func _init(selection:Array) -> void:
	node_ = selection[0]

func _ready() -> void:
	node_._begin_edit()
	node_.title_changed.connect(title_changed_)
	node_.end_edit_text.connect(queue_free)

func title_changed_(next_text:String) -> void:
	undo_.create_action("update")

	undo_.add_do_method(get_parent().clear_connections_.bind(node_))
	undo_.add_do_method(node_.interprit.bind(next_text))
	undo_.add_do_method(get_parent().add_connections_.bind(node_))

	undo_.add_undo_method(get_parent().clear_connections_.bind(node_))
	undo_.add_undo_method(node_.set_text.bind(node_.text))
	undo_.add_undo_method(get_parent().add_connections_.bind(node_))

	undo_.commit_action()
