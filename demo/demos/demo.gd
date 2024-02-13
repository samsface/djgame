extends CSGSphere3D

signal hit

var for_value_ := 0.0

func _ready() -> void:
	var tween := create_tween()
	#tween.tween_property(self, "scale", Vector3.ONE, 0.5)
	#tween.finished.connect(queue_free)

func watch(nob:Nob, for_value:float) -> void:
	if not nob:
		return

	for_value_ = for_value
	
	nob.value_changed.connect(_nob_value_changed)
	hit.connect(func(): nob.value_changed.disconnect(_nob_value_changed))

func _nob_value_changed(value:float) -> void:
	if abs(value - for_value_) < 0.1:
		pass
