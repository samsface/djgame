extends Node
class_name InputService

var relative := Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		relative = event.relative
		set_deferred("relative", Vector2.ZERO)
	
