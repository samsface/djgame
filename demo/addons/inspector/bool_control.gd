extends InspectorControl

func set_value(v):
	%Value.button_pressed = v

func _value_toggled(toggled_on: bool) -> void:
	value_changed.emit(%Value.button_pressed)
