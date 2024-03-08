extends Guide

const proximity_ := 0.1

var nob_
var for_value_ := 0.0
var last_off_ := 0.0
var length := 0.0
var auto := false

@onready var timer_ := $Timer
@onready var arrow_ := $Arrow
@onready var arrow__ := $Arrow/Arrow_

func _ready() -> void:
	last_off_ = get_off_()
	
	arrow_.position.y = 0.1
	
	var fall_time = length - (1.0 / 60)

	fall_tween_ = create_tween()
	fall_tween_.set_parallel()
	#fall_tween_.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	fall_tween_.tween_property(nob_, "scale:y", 1.0, 0.1).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	fall_tween_.tween_property(arrow_, "rotation:y", 5, fall_time)
	fall_tween_.tween_property(arrow_, "position:y", nob_.get_node("Top").position.y, fall_time)
	fall_tween_.finished.connect(_miss)

	points_ = points_service.make_points()
	
	if auto:
		arrow__.albedo = Color.PURPLE

func _miss() -> void:
	if hit_:
		return
		
	nob_.scale.y = 1.0
		
	miss_ = true
	
	arrow_.visible = false

	judge_accuracy_()
	
	nob_.value = for_value_

func _hit() -> void:
	if miss_:
		return

	nob_.scale.y = 1.0

	var combo:float = min(points_service.combo, 10.0)
	combo = combo / 10.0
	
	arrow__.explode(combo)

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
	if not auto:
		var off := get_off_()

		if abs(off) < proximity_:
			points_.hit(100)
			points_.commit()
		else:
			points_.miss(off)

		points_.global_position = global_position  

	wait_then_free_()

func wait_then_free_() -> void:
	$Arrow/Arrow_/Particles.emitting = false
	create_tween().tween_interval(0.5).finished.connect(queue_free)

func get_nob() -> Nob:
	return nob_
	
func get_off_() -> float:
	return nob_.value - for_value_

func _exit_tree() -> void:
	points_.queue_free()
	# just for when we reset during testing
	nob_.scale.y = 1.0
