extends Guide

signal hit
signal miss

const proximity_ := 0.1

var nob_
var for_value_ := 0.0
var hit_ := false
var miss_ := false
var last_off_ := 0.0

@onready var timer_ := $Timer
@onready var arrow_ := $Arrow

var text_service
var crowd_service

var sound_tween_:Tween
var sound_played_ := false

func _ready() -> void:
	last_off_ = get_off_()
	
	arrow_.position.y = 0.04

	var tween := create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(arrow_, "rotation:y", 5, 1.0)
	tween.tween_property(arrow_, "position:y", -0.002, 1.0)
	
	sound_tween_ = create_tween()
	sound_tween_.tween_interval(0.5)

	tween.finished.connect(_miss)

func _sound():
	if sound_played_:
		return
		
	sound_tween_.kill()

	sound_played_ = true
	
	crowd_service.cheer()

func _miss() -> void:
	if hit_:
		return
		
	miss_ = true
	
	arrow_.visible = false

	judge_accuracy_()

func _hit() -> void:
	if miss_:
		return

	var combo:float = min(get_parent().get_parent().combo_, 10.0)
	combo = combo / 10.0
	
	arrow_.explode(combo)

	hit_ = true

	var create := create_tween()
	create.tween_interval(0.05)
	await create.finished

	judge_accuracy_()

func watch(nob:Nob, for_value:float) -> void:
	if not nob:
		return
		
	for_value_ = for_value
	nob_ = nob

func _physics_process(delta: float) -> void:
	if hit_ or miss_:
		return

	if not timer_.is_stopped():
		return
		
	for node in get_parent().get_children():
		if node == self:
			break
		
		if not node.hit_ and not node.miss_:
			return

	var off = get_off_()
	
	# we moved way passed the target
	if sign(off) != sign(last_off_):
		_hit()
	# we're close
	elif abs(last_off_) < proximity_:
		_hit()
	else:
		last_off_ = off

func judge_accuracy_() -> void:
	var off := get_off_()

	if off > proximity_:
		text_service.make_too_high_text(global_position + Vector3.UP * 0.03)
	elif off < -proximity_:
		text_service.make_too_low_text(global_position + Vector3.UP * 0.03)
	else:
		if sound_tween_.is_running():
			_sound()
		text_service.make_pts_text(100, global_position + Vector3.UP * 0.03)

	wait_then_free_()

func wait_then_free_() -> void:
	$Arrow/Particles.emitting = false
	create_tween().tween_interval(0.5).finished.connect(queue_free)

func get_nob() -> Nob:
	return nob_
	
func get_off_() -> float:
	return nob_.value - for_value_
