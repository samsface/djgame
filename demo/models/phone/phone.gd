extends Node3D

func _input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	var p = $StaticBody3D.to_local(position) + Vector3(0.5, 0.0, 0.5)
	
	print(p)
	
	event.position = Vector2(p.x, p.z)
	event.position.x *= $SubViewport.size.x * 0.5
	event.position.y *= $SubViewport.size.y

	$SubViewport.push_input(event, false)
