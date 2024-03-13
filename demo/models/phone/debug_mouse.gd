extends Node2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var x = ColorRect.new()
		x.size = Vector2.ONE * 16.0
		x.position = event.position
		add_child(x)
		
