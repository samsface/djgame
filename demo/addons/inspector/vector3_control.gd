extends InspectorControl

func set_value(value) -> void:
	pass

func _value_changed(value):
	pass

func _use_camera_button_pressed():
	if get_tree().root.get_node("/root/Bus") and get_tree().root.get_node("/root/Bus").camera_service:
		value_changed.emit(Bus.camera_service.camera_.global_transform)
	else:
		value_changed.emit(Transform3D(Vector3.ONE, Vector3.ONE, Vector3.ONE, Vector3.ONE))
