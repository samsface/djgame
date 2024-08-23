@tool
extends Camera3D

func _physics_process(delta: float) -> void:
	var camera:Camera3D
	
	if Engine.is_editor_hint():
		camera = EditorInterface.get_editor_viewport_3d(0 ).get_camera_3d()
	else:
		var viewport = get_viewport()
		camera = viewport.get_camera_3d()
	
	#global_position = -camera.global_position
	global_position.y = 100
