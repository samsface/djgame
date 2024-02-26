extends SpotLight3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	be_a_laser_()

func be_a_laser_() -> void:
	var tween = create_tween()
	tween.set_speed_scale(5.0)
	tween.tween_property(self, "rotation", rotation + HyperRandom.random_vector3(), 0.1)
	tween.tween_property(self, "light_energy", 0.0, 0.1).set_delay(0.1)
	tween.tween_property(self, "light_energy", 16.0, 0.1).set_delay(0.2)
	tween.finished.connect(be_a_laser_)
