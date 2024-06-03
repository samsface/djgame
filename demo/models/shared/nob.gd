extends Node3D
class_name Nob

@export var scale_guide := 1.0

var intended_value := 0.0
var reset_to_intended_value_tween_:Tween
var path_follow:PathFollow3D

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

func slide(length, from_value, to_value, gluide) -> void:
	Bus.guide_service.slide(self, length, from_value, to_value, gluide)
	
func bang(length, value, auto, dilema_group, silent) -> void:
	Bus.guide_service.bang(self, length, value, auto, dilema_group, silent)

func update_path_follow_position_for_value(for_value:float) -> void:
	pass

func get_new_path_follow_and_remote_transform(for_value:float) -> PathFollow3D:
	var dup = path_follow.duplicate()
	path_follow.get_parent().add_child(dup)
	return dup
