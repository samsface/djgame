extends HBoxContainer

func _ready() -> void:
	child_entered_tree.connect(_reorganize)
	child_exiting_tree.connect(_reorganize)
	_reorganize(null)

func _reorganize(_node) -> void:
	for i in get_child_count():
		if i == 0:
			get_child(i).size_flags_horizontal = SIZE_SHRINK_BEGIN
		else:
			get_child(i).size_flags_horizontal = SIZE_SHRINK_END | SIZE_EXPAND
