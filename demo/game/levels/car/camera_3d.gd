@tool
extends Camera3D

func _physics_process(delta: float) -> void:
	var clip_map_size := 1024.0
	var clip_map_position_normalized:Vector3 = %ClipMap.global_position / clip_map_size
	clip_map_position_normalized += Vector3(-0.5, 0.0, -0.5)
	
	clip_map_position_normalized = clip_map_position_normalized.floor()
	clip_map_position_normalized += Vector3(1.0, 0.0, 1.0)
	
	global_position = clip_map_position_normalized * clip_map_size
	global_position.y = 100
