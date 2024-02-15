extends Node3D

var mouse_entered_ := false

func _mouse_entered() -> void:
	mouse_entered_ = true

func _mouse_exited() -> void:
	mouse_entered_ = false

func _input(event) -> void:
	if not mouse_entered_:
		return

	if event.is_action_pressed("click"):
		var p = $StaticBody3D.to_local(Camera.cursor.position) + Vector3(0.25, 0.0, 0.5)
		
		var e = InputEventMouseButton.new()
		e.button_index = 1
		e.pressed = true
		e.position = Vector2(p.x, p.z)
		e.position.x *= $SubViewport.size.x * 2.0
		e.position.y *= $SubViewport.size.y
		e.global_position = event.position
		e.button_mask = 1
		e.factor = 1.0
		$SubViewport.push_input(e, false)

func _input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var p = $StaticBody3D.to_local(position) + Vector3(0.25, 0.0, 0.5)
		
		print(p)
		
		event.position = Vector2(p.x, p.z)
		event.position.x *= $SubViewport.size.x * 2.0
		event.position.y *= $SubViewport.size.y

		$SubViewport.push_input(event, false)
