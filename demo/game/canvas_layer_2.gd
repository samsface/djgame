extends CanvasLayer

func _input(event):
	if event.is_action_pressed("toggle_dialog_editor"):
		visible = not visible
		Bus.camera_service.cursor.disabled = visible

