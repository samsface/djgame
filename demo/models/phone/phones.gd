extends Device

var mouse_entered_ := false

@export var free_click:bool :
	set(v):
		free_click = v
		
		if free_click:
			$StaticBody3D/CollisionShape3D.disabled = false
			$"0/StaticBody3D/CollisionShape3D".disabled = true
			$"ReplyA/StaticBody3D/CollisionShape3D".disabled = true
			$"ReplyB/StaticBody3D/CollisionShape3D".disabled = true
		else:
			$StaticBody3D/CollisionShape3D.disabled = true
			$"0/StaticBody3D/CollisionShape3D".disabled = false
			$"ReplyA/StaticBody3D/CollisionShape3D".disabled = false
			$"ReplyB/StaticBody3D/CollisionShape3D".disabled = false


func _mouse_entered() -> void:
	mouse_entered_ = true

func _mouse_exited() -> void:
	mouse_entered_ = false

func click(pos) -> void:
	pos = $StaticBody3D.to_local(pos)
	
	pos = Vector2(pos.x, pos.z)
	
	var shape_size = $StaticBody3D/CollisionShape3D.shape.size
	shape_size = Vector2(shape_size.x, shape_size.z)
	pos += shape_size * 0.5
	pos /= shape_size
	
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = true
	e.button_mask = 1
	e.position.x = pos.x
	e.position.y = pos.y
	e.global_position = e.position
	e.device = 444

	Input.parse_input_event(e)

	var e2 := e.duplicate()
	e2.pressed = false
	e2.button_mask = 0

	Input.parse_input_event(e2)

func _input(event) -> void:
	print(event)
	var automated = event.device == 444

	if not automated and not mouse_entered_:
		return

	if event.is_action("click"):
			
		#Bus.camera_service.camera_.fov = 50

		var p
		if automated:
			p = event.position
		else:
			p = $StaticBody3D.to_local(Bus.camera_service.cursor.position)
			p = Vector2(p.x, p.z)
			var shape_size = $StaticBody3D/CollisionShape3D.shape.size
			shape_size = Vector2(shape_size.x, shape_size.z)
			p += shape_size * 0.5
			p /= shape_size


		var e = event.duplicate()
		e.position = p
		e.position.x *= $SubViewport.size.x
		e.position.y *= $SubViewport.size.y
		e.global_position = e.position

		$SubViewport.push_input(e, false)

func vibrate() -> void:
	var its := 20
	
	var tween := create_tween()
	for i in its:
		var j = (float(its - i -1) / float(its))
		j *= 0.025
		var d = 1.0 if i % 2 == 0 else -1.0
		tween.tween_property($Phone, "position:x", j * d, 0.02)
