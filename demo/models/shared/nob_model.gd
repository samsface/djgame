extends Node3D

var hover_tween_:Tween
var rumble_tween_:Tween

var hover_scale := 1.1
var rumble_scale := 1.5

func hover_begin() -> void:
	if hover_tween_:
		hover_tween_.kill()

	hover_tween_ = create_tween()
	hover_tween_.set_trans(Tween.TRANS_ELASTIC)
	hover_tween_.set_ease(Tween.EASE_OUT)
	hover_tween_.tween_property(self, "scale", Vector3.ONE * hover_scale, 0.3)

func _grab_begin() -> void:
	Bus.camera_service.rumble.connect(_rumble)
	
func _grab_end() -> void:
	Bus.camera_service.rumble.disconnect(_rumble)

func hover_end() -> void:
	if hover_tween_:
		hover_tween_.kill()
	
	hover_tween_ = create_tween()
	hover_tween_.set_trans(Tween.TRANS_ELASTIC)
	hover_tween_.set_ease(Tween.EASE_OUT)
	hover_tween_.tween_property(self, "scale", Vector3.ONE, 0.3)

func _rumble() -> void:
	if rumble_tween_:
		rumble_tween_.kill()

	rumble_tween_ = create_tween()
	rumble_tween_.set_ease(Tween.EASE_OUT)
	rumble_tween_.tween_property(self, "scale", Vector3.ONE * rumble_scale, 0.05)
	rumble_tween_.tween_property(self, "scale", Vector3.ONE * hover_scale, 0.1)
