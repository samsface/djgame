extends Guide

signal done

var nob_
var to_value_ := 0.0
var duration_ := 0.0
var expected_value_ := 0.0
var score_ := 0
var slide_tween_:Tween
var score_tween_:Tween
var rumble_tween_:Tween
var rumble_scale_ := 1.2
var legato := false
var gluide_ := 0.0
var ref_count_ := 0

@onready var arrow_ = $arrow

func _ready() -> void:
	points_ = points_service.make_points()

func fall_() -> void:
	if fall_tween_:
		fall_tween_.kill()
	
	var g = Color("#00e659")
	g.a = 0.9

	fall_tween_ = create_tween()
	fall_tween_.set_parallel()
	fall_tween_.tween_property(nob_, "electric", g, 0.2)
	fall_tween_.tween_property(arrow_, "position:y", 0.0, gluide_).from(0.1)

func slide_() -> void:
	Bus.camera_service.rumble.connect(_rumble)
	
	if slide_tween_:
		slide_tween_.kill()

	slide_tween_ = create_tween()
	slide_tween_.set_parallel()
	slide_tween_.tween_property(arrow_, "global_position", nob_.get_guide_position_for_value(to_value_), duration_ - gluide_)
	slide_tween_.tween_property(self, "expected_value_", to_value_, duration_ - gluide_)
	slide_tween_.finished.connect(_done)

	if score_tween_:
		score_tween_.kill()

	score_tween_ = create_tween()
	score_tween_.tween_property(self, "score_", 300, duration_ - gluide_)

func _rumble() -> void:
	if rumble_tween_:
		rumble_tween_.kill()

	rumble_tween_ = create_tween()
	rumble_tween_.set_ease(Tween.EASE_OUT)
	rumble_tween_.tween_property(self, "scale", Vector3.ONE * rumble_scale_, 0.05)
	rumble_tween_.tween_property(self, "scale", Vector3.ONE, 0.1)

func watch(nob:Nob, from_value:float, to_value:float, duration:float, gluide:float, should_gluide:bool) -> void:
	if not nob:
		return

	nob_ = nob
	expected_value_ = from_value
	to_value_ = to_value
	duration_ = duration
	gluide_ = 1.5

	position = nob_.get_guide_position_for_value(expected_value_)
	arrow_.orient(
		nob_.get_guide_position_for_value(to_value_),
		nob_.get_guide_position_for_value(expected_value_)
	)

	fall_()
	await fall_tween_.finished

	slide_()

func test_() -> void:
	var off = nob_.value - expected_value_

	if abs(off) <= 0.2:
		score_tween_.play()
		points_.hit(score_, "")
	else:
		score_tween_.pause()
		points_.miss(10, "", true)

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
	nob_.electric = Color.TRANSPARENT

	hit_ = true

	var explode_size:float = min(points_service.combo, 10.0)
	explode_size = explode_size / 10.0
	
	points_.commit()

	await arrow_.explode(explode_size).finished
	
	queue_free()

func _exit_tree() -> void:
	#nob_.electric = Color.TRANSPARENT
	points_.queue_free()
