extends CanvasLayer


func _input(event):
	if event.is_action_pressed("toggle_piano_roll"):
		visible = not visible
