extends VSplitContainer

func _ready() -> void:
	await get_tree().process_frame
	if visible:
		Bus.camera_service.cursor.disabled = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_piano_roll"):
		visible = not visible
		
		if visible:
			Bus.camera_service.cursor.disabled = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Bus.camera_service.cursor.disabled = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
