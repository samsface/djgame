extends InspectorControl

var class_list_ := []

func set_value(v):
	%Value.node = v

func set_property(property) -> void:
	%Type.clear()
	class_list_.clear()
	for classname in get_inherited_classes_(property.class_name):
		class_list_.push_back(classname)
		%Type.add_item(classname.class)

func _item_selected(index: int) -> void:
	var script = load(class_list_[index].path).new()
	
	value_changed.emit(script)
