extends Label


func _ready() -> void:
	float_()

func float_() -> void:
	pivot_offset = size * 0.5
	
	var p = position
	
	var tween := create_tween()
	tween.set_speed_scale(0.5)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel()
	tween.tween_property(self, "position", p + Vector2.UP * 10.0, 1.0)
	tween.tween_property(self, "scale", Vector2.ONE * 1.1, 1.0)
	tween.tween_property(self, "rotation", 0.1, 1.0)
	
	await tween.finished

	tween = create_tween()
	tween.set_speed_scale(0.5)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel()
	tween.tween_property(self, "position", p, 1.0)
	tween.tween_property(self, "scale", Vector2.ONE, 1.0)
	tween.tween_property(self, "rotation", -0.1, 1.0)
	
	tween.finished.connect(float_)
