extends InspectorControl

func set_value(value) -> void:
	%X.value = value.x
	%Y.value = value.y
	%Z.value = value.z

func _value_changed(value):
	value_changed.emit(Vector3(%X.value, %Y.value, %Z.value))
