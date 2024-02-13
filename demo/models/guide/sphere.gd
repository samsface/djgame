extends Guide

signal hit
signal miss

const proximity_ := 0.1

var nob_
var for_value_ := 0.0
var hit_ := false
var miss_ := false
var last_off_ := 0.0

func _ready() -> void:
	var color = HyperRandom.fruity_color()
	
	$Icosphere/OmniLight3D.light_color = color
	$Icosphere.set_instance_shader_parameter("albedo", color);
	
	$Icosphere.position.y = 0.04
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property($Icosphere, ^"rotation:y", 5, 1.0)
	tween.tween_property($Icosphere, ^"position:y", -0.005, 1.0)
	tween.tween_property($Icosphere/OmniLight3D, ^"light_energy", 1.0, 1.0)
	#tween.tween_property($Icosphere, ^"instance_shader_parameters/bang", 1.0, 0.5)
	#tween.tween_property($Icosphere, ^"instance_shader_parameters/danger", 1.0, 0.2)
	tween.finished.connect(_miss)

func _miss() -> void:
	if hit_:
		return
		
	miss_ = true
	
	$Icosphere.visible = false

	miss.emit(get_off_())
	wait_then_free_()

func _hit() -> void:
	if miss_:
		return

	hit_ = true

	nob_.value_changed.disconnect(_nob_value_changed)
	var tween = create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property($Icosphere, ^"instance_shader_parameters/ttl", 1.0, 0.35)
	tween.tween_property($Icosphere/OmniLight3D, ^"light_energy", 0.0, 0.35)
	$Icosphere.set_instance_shader_parameter("ttl2", 1.0);
	
	wait_for_accuracy_()

func watch(nob:Nob, for_value:float) -> void:
	if not nob:
		return
		
	for_value_ = for_value
	nob_ = nob
	nob_.value_changed.connect(_nob_value_changed)

	await nob.get_tree().process_frame

	last_off_ = get_off_()

	if abs(last_off_) < proximity_:
		_hit()

func _nob_value_changed(value:float, old_value:float) -> void:
	var off = get_off_()
	
	# we moved way passed the target
	if sign(off) != sign(last_off_):
		_hit()
	# we're close
	elif abs(last_off_) < proximity_:
		_hit()
	else:
		last_off_ = off

func wait_for_accuracy_() -> void:
	var create := create_tween()
	create.tween_interval(0.05)
	await create.finished
	
	var off := get_off_()

	if off > proximity_:
		miss.emit(off)
	elif off < -proximity_:
		miss.emit(off)
	else:
		hit.emit(off)
	
	wait_then_free_()
	
func wait_then_free_() -> void:
	create_tween().tween_interval(0.3).finished.connect(queue_free)

func get_nob() -> Nob:
	return nob_
	
func get_off_() -> float:
	return nob_.value - for_value_
