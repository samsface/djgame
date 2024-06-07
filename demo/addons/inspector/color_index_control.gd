extends InspectorControl

func set_value(value) -> void:
	%Value.colors = value

func _value_changed() -> void:
	value_changed.emit(%Value.colors)
