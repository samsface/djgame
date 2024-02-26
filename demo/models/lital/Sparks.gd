extends GPUParticles3D

var tween_:Tween

func spark() -> void:
	if tween_:
		tween_.kill()
	
	emitting = true
	tween_ = create_tween()
	tween_.tween_property(self, "emitting", false, 0.0).set_delay(0.02)
