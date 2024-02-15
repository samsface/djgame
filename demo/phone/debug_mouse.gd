extends Node2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print(event.position)
		var x = ColorRect.new()
		x.size = Vector2.ONE * 4.0
		x.position = event.position
		add_child(x)
		
