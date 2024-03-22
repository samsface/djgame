extends InspectorControl

func set_value(v):
	%Value.text = v

func _value_changed(value):
	value_changed.emit(value)

func _value_changed_alt():
	value_changed.emit($Value.text)

