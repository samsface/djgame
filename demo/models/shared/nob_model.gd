extends Node3D

var hover_tween_:Tween

func hover_begin() -> void:
	if hover_tween_:
		hover_tween_.kill()

	hover_tween_ = create_tween()
	hover_tween_.set_trans(Tween.TRANS_ELASTIC)
	hover_tween_.set_ease(Tween.EASE_OUT)
	hover_tween_.tween_property(self, "scale", Vector3.ONE * 1.1, 0.3)

func hover_end() -> void:
	if hover_tween_:
		hover_tween_.kill()
	
	hover_tween_ = create_tween()
	hover_tween_.set_trans(Tween.TRANS_ELASTIC)
	hover_tween_.set_ease(Tween.EASE_OUT)
	hover_tween_.tween_property(self, "scale", Vector3.ONE, 0.3)
