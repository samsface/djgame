extends StaticBody3D

func _physics_process(delta: float) -> void:
	position.x = Camera.cursor.position.x
	position.z = Camera.cursor.position.z
	position.y = 0.06
