extends CanvasLayer

func _input(event):
	var cursor = $"../../SubViewportContainer/SubViewport/Game/Camera/Cursor/"
	
	if event.is_action_pressed("toggle_piano_roll"):
		$VSplitContainer/BeatPlayerHost.visible = not $VSplitContainer/BeatPlayerHost.visible

	if event.is_action_pressed("ui_cancel"):
		cursor.disabled = not cursor.disabled
