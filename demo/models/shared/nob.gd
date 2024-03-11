extends Node3D
class_name Nob

@export var scale_guide := 1.0

var intended_value := 0.0
var reset_to_intended_value_tween_:Tween

func get_guide_position_for_value(value:float) -> Vector3:
	return global_position

func get_nob_position() -> Vector3:
	return global_position

func reset_to_intended_value(delay:float = 0.3) -> void:
	if reset_to_intended_value_tween_:
		reset_to_intended_value_tween_.kill()

	reset_to_intended_value_tween_ = create_tween()
	reset_to_intended_value_tween_.tween_interval(delay)
	reset_to_intended_value_tween_.finished.connect(reset_)

func reset_() -> void:
	set("value", intended_value)

func slide(length, from_value, to_value) -> void:
	Camera.guide_service.slide(self, length, from_value, to_value)
	
func bang(length, value, auto) -> void:
	Camera.guide_service.bang(self, length, value, auto)
