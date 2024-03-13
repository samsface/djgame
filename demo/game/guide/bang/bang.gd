extends Guide

const proximity_ := 0.1

var nob_
var for_value_ := 0.0
var last_off_ := 0.0
var length := 0.0
var auto := false

@onready var timer_ := $Timer
@onready var arrow__ := $Arrow___/Arrow_

func color_() -> Color:
	if auto:
		return Color.PURPLE
	else:
		return Color("#00e659")

func emission_color_() -> Color:
	if auto:
		return Color.BLUE
	else:
		return Color.GREEN

func _ready() -> void:
	scale = Vector3.ONE * nob_.scale_guide * 0.02

	last_off_ = get_off_()

	nob_.remote_transform.remote_path = get_path()
	nob_.remote_transform.rotation
	nob_.path_follow.progress_ratio = 0.0

	var fall_time = length - (1.0 / 60)

	fall_tween_ = create_tween()
	fall_tween_.set_parallel()
	
	arrow__.albedo = color_()

	var g = emission_color_()
	g.a = 0.8
	fall_tween_.tween_property(nob_, "electric", g, 0.2)

	fall_tween_.tween_property(nob_.remote_transform, "rotation:z", 5, fall_time)
	fall_tween_.tween_property(nob_.path_follow, "progress_ratio", 1.0, fall_time)
	fall_tween_.finished.connect(_miss)

	points_ = points_service.make_points()
	points_.scale = Vector3.ONE * nob_.scale_guide

func _miss() -> void:
	if hit_:
		return
		
	#nob_.electric = Color.TRANSPARENT

	miss_ = true
	
	visible = false

	judge_accuracy_()
	
	nob_.value = for_value_

func _hit() -> void:
	if miss_:
		return

	#nob_.electric = Color.TRANSPARENT

	var combo:float = min(points_service.combo, 10.0)
	combo = combo / 10.0
	
	arrow__.explode(combo)

	hit_ = true

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
	var end_tween := create_tween()
	end_tween.set_parallel()
	
	var ec = emission_color_()
	var eca = ec
	eca.a = 0
	
	end_tween.tween_property(nob_, "electric", ec, 0.1)
	end_tween.tween_property(nob_, "electric", eca, 0.1).set_delay(0.1)

	nob_.remote_transform.remote_path = NodePath()
	$Arrow___/Arrow_/Particles.emitting = false
	end_tween.tween_interval(0.8).finished.connect(queue_free)

func get_nob() -> Nob:
	return nob_
	
func get_off_() -> float:
	return nob_.value - for_value_

func _exit_tree() -> void:
	points_.queue_free()
	# just for when we reset during testing
	#nob_.scale.y = 1.0
	#nob_.electric = Color.TRANSPARENT
