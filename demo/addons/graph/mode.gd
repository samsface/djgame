extends Node2D
class_name GraphControlMode

func block() -> bool:
	return true

func _cancel() -> void:
	queue_free()
