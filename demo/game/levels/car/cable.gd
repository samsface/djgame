extends MeshInstance3D

@export var resolution:int

func link(begin:Vector3, end:Vector3) -> void:
	var mid_point := (begin + end) * 0.5
	global_position = mid_point
	
	var distance = begin.distance_to(end)
	
	mesh.height = distance
	mesh.rings = distance / max(resolution, 1)
	
