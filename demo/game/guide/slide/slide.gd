extends Guide

signal hit
signal miss

var nob_
var to_value_ := 0.0
var duration_ := 0.0
var expected_value_ := 0.0

var first_hit_ := false
var fall_tween_:Tween
var text_

var hit_ := false
var miss_ := false

var score_ := 0

@onready var arrow_ = $arrow

var score_tween_:Tween
var rumble_tween_:Tween
var rumble_scale_ := 1.2

var text_service
var points_service

func _ready() -> void:
	var fall_duration := 0.5
	
	arrow_.orient(
		nob_.get_guide_position_for_value(to_value_),
		nob_.get_guide_position_for_value(expected_value_)
	)

	fall_tween_ = create_tween()
	fall_tween_.set_parallel()
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

	text_ = text_service.make_text()

	test_()
	
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

var first_ := true

func test_(finished := false) -> void:
	if finished:
		text_.text = str(score_) + " PTS"
		text_.ok()
		return

	var off = nob_.value - expected_value_
	if abs(off) <= 0.2:
		score_tween_.play()
		text_.text = ("%d" % score_) + " PTS"
		text_.ok()

	elif off > 0.2:
		score_tween_.pause()
		text_.text = "TOO HIGH!"
		text_.danger()
	elif off < 0.2:
		score_tween_.pause()
		text_.text = "TOO LOW!"
		text_.danger()

	text_.global_position = get_nob().get_nob_position() + Vector3.UP * 0.03

func _physics_process(delta: float) -> void:
	if hit_:
		return

	if fall_tween_.is_running():
		return

	test_()

func get_nob() -> Nob:
	return nob_

func _done() -> void:
	points_service.points += score_

	text_.queue_free()
	$arrow/Particles.emitting = false
	
	hit_ = true
	test_(true)
	await arrow_.explode().finished
	queue_free()
