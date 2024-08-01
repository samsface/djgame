extends ColorRect

func _physics_process(delta):
	global_position.x = get_parent().global_position.x
