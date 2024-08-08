extends Window

func _on_focus_entered():
	Bus.camera_service.cursor.disabled = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	if Input.is_action_just_pressed("toggle_piano_roll"):
		visible = not visible
		if visible:
			get_tree().root.position.y = 0
			grab_focus()
			size.x = DisplayServer.screen_get_size(0).x
