extends InspectorControl

func set_value(value) -> void:
	%X.value = value.x
	%Y.value = value.y

func _value_changed(value):
	value_changed.emit(Vector2(%X.value, %Y.value))
