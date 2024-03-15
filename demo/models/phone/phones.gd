extends Device

var mouse_entered_ := false

func _mouse_entered() -> void:
	mouse_entered_ = true

func _mouse_exited() -> void:
	mouse_entered_ = false

func click(pos:Vector3) -> void:
	pos = $StaticBody3D.to_local(pos)
	
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = true
	e.button_mask = 1
	e.position.x = pos.x
	e.position.y = pos.z
	e.global_position = e.position
	e.device = 444

	Input.parse_input_event(e)

	var e2 := e.duplicate()
	e2.pressed = false
	e2.button_mask = 0

	Input.parse_input_event(e2)

func _input(event) -> void:
	var automated = event.device == 444
	
	if not automated and not mouse_entered_:
		return

	if event.is_action("click"):
		var p
		if automated:
			p = event.position
		else:
			p = $StaticBody3D.to_local(Camera.cursor.position)
			p = Vector2(p.x, p.z)

		p += Vector2(0.25, 0.5)

		var e = event.duplicate()
		e.position = p
		e.position.x *= $SubViewport.size.x * 2.0
		e.position.y *= $SubViewport.size.y
		e.global_position = event.position

		$SubViewport.push_input(e, false)

func vibrate() -> void:
	var its := 20
	
	var tween := create_tween()
	for i in its:
		var j = (float(its - i -1) / float(its))
		j *= 0.025
		var d = 1.0 if i % 2 == 0 else -1.0
		tween.tween_property($Phone, "position:x", j * d, 0.02)
