extends Guide

var nob_
var to_value_ := 0.0
var duration_ := 0.0
var expected_value_ := 0.0
var score_ := 0
var score_tween_:Tween
var rumble_tween_:Tween
var rumble_scale_ := 1.2

@onready var arrow_ = $arrow

func _ready() -> void:
	var fall_duration := 0.5
	
	arrow_.orient(
		nob_.get_guide_position_for_value(to_value_),
		nob_.get_guide_position_for_value(expected_value_)
	)

	var g = Color("#00e659")
	g.a = 0.9

	fall_tween_ = create_tween()
	fall_tween_.set_parallel()
	
	fall_tween_.tween_property(nob_, "electric", g, 0.2)
	
	arrow_.position.y = 0.04
	fall_tween_.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	fall_tween_.tween_property(arrow_, "position:y", 0.0, fall_duration)

	await fall_tween_.finished

	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(arrow_, "global_position", nob_.get_guide_position_for_value(to_value_), duration_ - fall_duration)
	tween.tween_property(self, "expected_value_", to_value_, duration_ - fall_duration)
	
	tween.finished.connect(_done)

	score_tween_ = create_tween()
	score_tween_.tween_property(self, "score_", 300, duration_ - fall_duration)

	points_ = points_service.make_points()

	Camera.rumble.connect(_rumble)
	
	

func _rumble() -> void:
	if rumble_tween_:
		rumble_tween_.kill()

	rumble_tween_ = create_tween()
	rumble_tween_.set_ease(Tween.EASE_OUT)
	rumble_tween_.tween_property(self, "scale", Vector3.ONE * rumble_scale_, 0.05)
	rumble_tween_.tween_property(self, "scale", Vector3.ONE, 0.1)

func watch(nob:Nob, from_value:float, to_value:float, duration:float) -> void:
	if not nob:
		return

	nob_ = nob
	expected_value_ = from_value
	to_value_ = to_value
	duration_ = duration

func test_() -> void:
	var off = nob_.value - expected_value_

	if abs(off) <= 0.2:
		score_tween_.play()
		points_.hit(score_)
	else:
		score_tween_.pause()
		points_.miss(off)

	points_.global_position = get_nob().get_nob_position()

func _physics_process(delta: float) -> void:
	if hit_:
		return

	if fall_tween_.is_running():
		return

	test_()

func get_nob() -> Nob:
	return nob_

func _done() -> void:
	$arrow/Particles.emitting = false

	hit_ = true

	var explode_size:float = min(points_service.combo, 10.0)
	explode_size = explode_size / 10.0
	
	points_.commit()

	await arrow_.explode(explode_size).finished
	queue_free()

func _exit_tree() -> void:
	nob_.electric = Color.TRANSPARENT
	points_.queue_free()
