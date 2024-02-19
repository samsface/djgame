extends Node3D

var mouse_entered_ := false

func _mouse_entered() -> void:
	mouse_entered_ = true

func _mouse_exited() -> void:
	mouse_entered_ = false

func _input(event) -> void:
	if not mouse_entered_:
		return

	if event.is_action("click"):
		var p = $StaticBody3D.to_local(Camera.cursor.position) + Vector3(0.25, 0.0, 0.5)

		var e = event.duplicate()
		e.position = Vector2(p.x, p.z)
		e.position.x *= $SubViewport.size.x * 2.0
		e.position.y *= $SubViewport.size.y
		e.global_position = event.position
		$SubViewport.push_input(e, false)
		
		Camera.smooth_look_at(self)
		Camera.set_head_position($Head.global_position)

func _input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var p = $StaticBody3D.to_local(position) + Vector3(0.25, 0.0, 0.5)

		event.position = Vector2(p.x, p.z)
		event.position.x *= $SubViewport.size.x * 2.0
		event.position.y *= $SubViewport.size.y

		$SubViewport.push_input(event, false)
		
func vibrate() -> void:
	var its := 20
	
	var tween := create_tween()
	for i in its:
		var j = (float(its - i -1) / float(its))
		j *= 0.025
		var d = 1.0 if i % 2 == 0 else -1.0
		tween.tween_property($Phone, "position:x", j * d, 0.02)
