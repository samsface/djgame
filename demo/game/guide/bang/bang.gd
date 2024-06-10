extends Guide

signal hit

const proximity_ := 0.1

var nob_
var for_value_ := 0.0
var last_off_ := 0.0
var length := 0.0
var time := 0
var auto := false

@onready var timer_ := $Timer
@onready var arrow__ := $Arrow___/Arrow_

var dilema_group := 0
var fall_time_ := 0.0

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

	var path_follow = nob_.get_new_path_follow_and_remote_transform(for_value_)
	tree_exited.connect(path_follow.queue_free)
		
	var remote_transform:RemoteTransform3D = path_follow.get_child(0)
	#nob_.update_path_follow_position_for_value(for_value_)
	remote_transform.remote_path = get_path()
	remote_transform.rotation.z = 0
	path_follow.progress_ratio = 0.0

	fall_time_ = length

	fall_tween_ = create_tween()
	fall_tween_.set_parallel()
	arrow__.albedo = color_()

	var g = emission_color_()
	g.a = 0.8
	fall_tween_.tween_property(nob_, "electric", g, min(fall_time_, 0.2))

	fall_tween_.tween_property(remote_transform, "rotation:z", 5, fall_time_)
	fall_tween_.tween_property(path_follow, "progress_ratio", 1.0, fall_time_)
	fall_tween_.finished.connect(_miss)

	points_ = points_service.make_points()
	tree_exited.connect(points_.queue_free)
	points_.scale = Vector3.ONE * nob_.scale_guide
	
	nob_.value_changed.connect(_nob_value_changed)
	
	nob_.buffer_change(time, for_value_)

func _nob_value_changed(value:float) -> void:
	if not active:
		return

	if value != for_value_:
		return
	
	# too far away, ignore
	if ((fall_time_) - fall_tween_.get_total_elapsed_time()) > 0.2:
		return
			
	_hit()

func _miss() -> void:
	if hit_:
		return
	
	if miss_:
		return
	

	done.emit()
	
	miss_ = true
	
	visible = false

	nob_.value = for_value_
	
	await get_tree().physics_frame

	judge_accuracy_()

func _hit() -> void:
	if hit_:
		return
	
	if miss_:
		return
	
	done.emit()
	

	var combo:float = min(points_service.combo, 10.0)
	combo = combo / 10.0
	
	arrow__.explode(combo)

	hit_ = true
	
	hit.emit()

	judge_accuracy_()

func watch(nob:Nob, for_value:float) -> void:
	if not nob:
		return

	for_value_ = for_value
	nob_ = nob

func _physics_process(delta: float) -> void:
	if hit_ or miss_:
		return

	#if not timer_.is_stopped():
	#	return

	for node in get_parent().get_children():
		if node == self:
			break
		
		#if not node.hit_ and not node.miss_:
		#	return

	var off = get_off_()
	
	# we moved way passed the target
	if sign(off) != sign(last_off_):
		_hit()
	# we're close
	elif abs(last_off_) < proximity_:
		_hit()
	else:
		last_off_ = off

func score_(off_time) -> int:
	if off_time <= .1:
		return 100
	if off_time <= .2:
		return 50
	if off_time <= .3:
		return 25
	else:
		return 5

func judge_accuracy_() -> void:
	if not auto:
		var off := get_off_()

		if abs(off) < proximity_:
			var off_time := get_off_time_()
			points_.hit(score_(off_time), "< " + str(int(off_time * 10)) + " ms")
			points_.commit()
		else:
			if dilema_group == 0:
				points_.miss(100, "too slow")
				points_.commit()

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

	$Arrow___/Arrow_/Particles.emitting = false
	end_tween.tween_interval(0.8).finished.connect(queue_free)

func get_nob() -> Nob:
	return nob_
	
func get_off_() -> float:
	return nob_.value - for_value_

func get_off_time_() -> float:
	return fall_time_ - fall_tween_.get_total_elapsed_time()

