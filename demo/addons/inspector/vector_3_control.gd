extends InspectorControl

func set_value(value) -> void:
	if value is not Vector3:
		return

	%X.value = value.x
	%Y.value = value.y
	%Z.value = value.y

func _value_changed(value):
	value_changed.emit(Vector3(%X.value, %Y.value, %Z.value))
