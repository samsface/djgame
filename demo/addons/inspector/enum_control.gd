extends InspectorControl

func set_value(v):
	%Value.select(v)

func _item_selected(index):
	value_changed.emit(index)
