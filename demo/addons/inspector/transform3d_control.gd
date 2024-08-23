extends InspectorControl

func set_value(value) -> void:
	pass

func _value_changed(value):
	pass

func _use_camera_button_pressed():
	if get_tree().root.get_node("/root/Bus") and get_tree().root.get_node("/root/Bus").camera_service:
		var t = Bus.camera_service.camera_.global_transform
		t.origin -= Bus.camera_service.get_parent().global_position
		t = t.rotated(Vector3.UP, -Bus.camera_service.get_parent().global_rotation.y)
		#t.basis = Basis(t.basis.get_rotation_quaternion() -  Bus.camera_service.get_parent().global_transform.basis.get_rotation_quaternion())

		value_changed.emit(t)
	else:
		value_changed.emit(Transform3D(Vector3.ONE, Vector3.ONE, Vector3.ONE, Vector3.ONE))
