extends InspectorControl

func set_value(v):
	%Value.button_pressed = v

func _value_toggled(value):
	value_changed.emit(value)
