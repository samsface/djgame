extends Guide
class_name BangGuide

signal hit

const proximity_ := 0.1

var nob_
var for_value_ := 0.0
var last_off_ := 0.0
var length := 0.0
var time := 0
var auto := false
var silent := false
var duration := 0.0
var done_ := false#
var waiting_for_nob_release_ := false

@onready var timer_ := $Timer
@onready var arrow__ := $Arrow___/Arrow_

var dilema_group := 0
var latency_time_ := 0.0
var fall_time_ := 0.0
var tail_time_ := 0.0
var no_tail_time_ = false
var velocity_ := Vector3.ZERO
var v_ := 0.0

func color_() -> Color:
	if auto:
		return Color.PURPLE
	else:
		return Color.GREEN

func emission_color_() -> Color:
	if auto:
		return Color.BLUE
	else:
		return Color.GREEN

func _ready() -> void:
	if not nob_.top:
		done.emit()
		queue_free()
		return
		
	visible = false
		
	latency_time_ = Bus.audio_service.latency

	fall_time_ = length
	
	#fall_tween_ = create_tween()
	#fall_tween_.set_parallel()

	scale = Vector3.ONE * nob_.scale_guide * 0.02
	global_position = nob_.top.global_position + Vector3.UP * 0.1 + Vector3.ONE * 0.0001
	look_at(nob_.top.global_position)
	
	var x = global_position.distance_to(nob_.top.global_position)
	
	velocity_ = (global_position.direction_to(nob_.top.global_position) * x) / fall_time_
	
	v_ = x / (fall_time_)
	

	tail_time_ = duration
	if tail_time_ == 0.0:
		no_tail_time_ = true

	arrow__.albedo = color_()
	
	points_ = points_service.make_points("hp")
	tree_exited.connect(points_.queue_free)
	points_.scale = Vector3.ONE * nob_.scale_guide
	
	#rotate_object_local(Vector3(0, 0, 1), randf() * PI)
	
func set_active() -> void:
	if nob_.value > 0.0:
		waiting_for_nob_release_ = true
		nob_.value_changed.connect(func(value): 
				waiting_for_nob_release_ = false)

func _done() -> void:
	if done_:
		return
	
	active = false
	done_ = true

	if points_.points <= 0:
		points_.points = -100
	
	points_.commit()
	done.emit()
	
	arrow__.visible = false
	
	get_tree().create_timer(0.2).timeout.connect(queue_free)
	
	nob_.electric =  Color.TRANSPARENT

func _physics_process(delta: float) -> void:
	if latency_time_ > 0.0:
		latency_time_ -= delta
		return

	visible = true
		
	if active:
		nob_.electric.r = 0
		nob_.electric.g = 1
		nob_.electric.b = 0
		nob_.electric.a = lerp(nob_.electric.a, 1.0, delta)

	if active and not waiting_for_nob_release_:
		if nob_.value > 0.0:
			if fall_time_ < 0.2:
				points_.points += 1
				
				nob_.electric = Color.GREEN
				arrow__.freq = 100.0
				arrow__.amp = lerp(arrow__.amp, 0.02, delta * 30.0)
				arrow__.transparency = 1.0

			else:
				points_.points -= 1

			points_.global_position = global_position - Vector3.FORWARD * 0.01

	if no_tail_time_:
		arrow__.length = 0.01
	else:
		arrow__.length = (tail_time_ * v_) * 2.0

	fall_time_ -= delta
	
	if fall_time_ <= 0.0:
#
		tail_time_ -= delta

		if tail_time_ <= 0.0:
			_done()
	else:
		global_position += velocity_ * delta
		#rotate_object_local(Vector3(0, 0, 1), delta * 2.0)
