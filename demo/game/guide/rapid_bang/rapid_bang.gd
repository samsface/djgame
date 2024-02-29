extends Guide

const proximity_ := 0.1

var nob_
var for_value_ := 0.0
var range_value_ := 0.0
var last_off_ := 0.0
var hits_ := 0

@onready var timer_ := $Timer
@onready var arrow_ := $Arrow

func _ready() -> void:
	last_off_ = get_off_()
	points_ = points_service.make_points()
	reset_()

func reset_() -> void:
	arrow_.position.y = 0.04

	fall_tween_ = create_tween()
	fall_tween_.set_parallel()
	fall_tween_.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	fall_tween_.tween_property(arrow_, "rotation:y", 5, 1.0)
	fall_tween_.tween_property(arrow_, "position:y", -0.002, 1.0)

func _hit() -> void:
	hits_ += 1

	var explode_size:float = min(hits_ * 0.1, 10.0)
	explode_size = explode_size / 10.0
	
	arrow_.explode(explode_size)

	points_.hit(100)
	points_.global_position = global_position 
	
	reset_()

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

func get_nob() -> Nob:
	return nob_
	
func get_off_() -> float:
	return nob_.value - for_value_

func _exit_tree() -> void:
	points_.queue_free()
