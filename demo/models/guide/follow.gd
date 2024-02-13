extends Guide

signal hit
signal miss

var nob_
var to_value_ := 0.0
var duration_ := 0.0
var expected_value_ := 0.0

var first_hit_ := false

func _ready() -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property($CSGBox3D, "global_position", nob_.get_guide_position_for_value(to_value_), duration_)
	tween.tween_property(self, "expected_value_", to_value_, duration_)
	tween.finished.connect(queue_free)
	
	PureData.bang.connect(_bang)

func watch(nob:Nob, from_value:float, to_value:float, duration:float) -> void:
	if not nob:
		return

	nob_ = nob
	expected_value_ = from_value
	to_value_ = to_value
	duration_ = duration

func _physics_process(delta: float) -> void:
	pass

func _bang(r):
	if r == "s-clock-4":
		var off = nob_.value - expected_value_
		if abs(off) < 0.1:
			hit.emit(off)
		else:
			miss.emit(off)

func get_nob() -> Nob:
	return nob_

