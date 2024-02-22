extends Node3D

func _physics_process(delta: float) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Noodle.atoms_[-1].position.z = get_viewport().get_mouse_position().x * -0.003
	$Noodle.atoms_[-1].position.y = get_viewport().get_mouse_position().y * -0.003
