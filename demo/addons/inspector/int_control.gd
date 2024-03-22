extends InspectorControl

func set_value(value) -> void:
	%Value.value = value

func _value_changed(value):
	value_changed.emit(value)
