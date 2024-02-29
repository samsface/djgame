extends Node

signal play

var tracks_ := {}
var beat_ := 0
var recording_ := 0
var playing_ := false
var animation_player_:AnimationPlayer
var max_time_ := 0
var tempo_ := 0.13
var capturing_nob_:Nob

func _ready() -> void:
	Camera.recorder = self
	
	PureData.bind("s-clock-beat")
	PureData.bang.connect(_bang)
	
	await get_tree().process_frame
	
	animation_player_ = $AnimationPlayer
	animation_player_.play("test/scene2")

	max_time_ = get_last_data_time()

	$CanvasLayer/HSlider/ProgressBar.value = max_time_
	
	idk_()
	
	$AnimationPlayer.speed_scale = (1.0 / tempo_) * 0.25
	#dump_()

func get_animation_() -> Animation:
	var al:Animation = animation_player_.libraries["test"].get_animation("scene2")
	return al

func _bang(r):
	if r == "s-clock-beat":
		#if beat_ % 32 == 0:
			#Camera.set_head_position(get_node("../acid").get_view_position(Camera.get_head_position()))
		
		beat_ += 1
		#if beat_ > max_time_:
		#	animation_player_.active = false
		_sider_value_changed(beat_, false)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("record"):
		record_()
	elif Input.is_action_just_pressed("play"):
		play_()

func play_() -> void:
	if playing_:
		playing_ = false
		PureData.send_bang("r-STOP")
		animation_player_.active = false
	else:
		playing_ = true
		PureData.send_bang("r-RESET")
		PureData.send_bang("r-PLAY")
		animation_player_.active = true
		play.emit()

func record_() -> void:
	if recording_ == 2:
		recording_ = 0
		Camera.recording = false
		$CanvasLayer/Label.text = ""
		dump_()
	
	else:
		recording_ += 1
		if recording_ == 1:
			$CanvasLayer/Label.text = "ARMING"
		else:
			Camera.recording = true
			$CanvasLayer/Label.text = "RECORDING"
			capture(capturing_nob_)
			play_()

func get_keyframe(animation:Animation, track_idx:int, key_idx):
	return {
		idx = key_idx,
		time = animation.track_get_key_time(track_idx, key_idx),
		value = animation.bezier_track_get_key_value(track_idx, key_idx)
	}

func remove_self_track() -> void:
	var animation = get_animation_()
	var track_idx := animation.find_track(get_path(), Animation.TYPE_METHOD)
	if track_idx != -1:
		animation.remove_track(track_idx)

func round_to_decimal(number, decimalPlaces):
	var multiplier = pow(10, decimalPlaces)
	return round(number * multiplier) / multiplier
	
func snap(value:float, by:float) -> float:
	return Vector2(value, value).snapped(Vector2(by, by)).x

func smooth_() -> void:
	var time := 0.0
	var sum := 0.0
	var count := 0.0
	var smoothed := {}

	var animation = get_animation_()
	for track_idx in animation.get_track_count():
		var key_count := animation.track_get_key_count(track_idx)

		var smooths := []
		smoothed[animation.track_get_path(track_idx)] = smooths
		
		for key_idx in key_count:
			var v = get_keyframe(animation, track_idx, key_idx)

			if v.time >= time + 0.1:
				smooths.push_back([time, snap(sum / count, 0.1)])

				sum = 0.0
				count = 0.0
				time = snap(v.time, 0.25)
			
			sum += v.value
			count += 1
	
	while animation.get_track_count():
		animation.remove_track(0)

	for s in smoothed:
		var ss = smoothed[s]

		if ss.size() == 0:
			continue

		var sn := []

		sn.push_back(ss[0])

		for i in range(1, ss.size() - 1):
			var slope1 = ss[i][1] - ss[i-1][1]
			var slope2 = ss[i+1][1] - ss[i][1]
			var slope = abs(slope1 - slope2)
			
			if slope > 0.05:
				sn.push_back(ss[i])

		smoothed[s] = sn
			
	for s in smoothed:
		var track_idx = animation.add_track(Animation.TYPE_BEZIER)
		animation.track_set_path(track_idx, s)
		for i in smoothed[s].size():
			animation.bezier_track_insert_key(track_idx, smoothed[s][i][0], smoothed[s][i][1])

func capture(node:Nob) -> void:
	if not node:
		return

	capturing_nob_ = node

	if recording_ != 2:
		return

	var animation:Animation = get_animation_()
	var node_path = NodePath(str(node.get_path()) + ":value")
	var track_idx := animation.find_track(node_path, Animation.TYPE_BEZIER)
	if track_idx == -1:
		track_idx = animation.add_track(Animation.TYPE_BEZIER)
		animation.track_set_path(track_idx, node_path)
	animation.track_set_enabled(track_idx, false)

	var current_time = animation_player_.current_animation_position
	animation.bezier_track_insert_key(track_idx, current_time, node.value)


func dump_() -> void:
	remove_self_track()
	smooth_()

	ResourceSaver.save(get_animation_(), "res://junk/test2.tres")

func get_last_data_time() -> int:
	var animation:Animation = get_animation_()

	var max_key_time := 0.0

	for track_idx in animation.get_track_count():
		var key_count = animation.track_get_key_count(track_idx)
		if key_count > 0:
			var key_time = animation.track_get_key_time(track_idx, key_count - 1)
			
			if max_key_time < key_time:
				max_key_time = key_time

	return max_key_time


var hack_ := false
func _sider_value_changed(value:int, seek := true) -> void:
	if hack_:
		return

	$CanvasLayer/HSlider/Label.text = str(value)
	
	if $CanvasLayer/HSlider.value != value:
		hack_ = true
		$CanvasLayer/HSlider.value = value
		hack_ = false

	if seek:
		beat_ = value
		var animation:Animation = get_animation_()
		animation_player_.active = true
		animation_player_.seek(value, true)
		animation_player_.active = false

func get_meta_track_idx() -> int:
	var animation:Animation = get_animation_()
	
	var root = animation_player_.get_node(animation_player_.root_node)
	
	for track_idx in animation.get_track_count(): 
		var node_path := animation.track_get_path(track_idx)
		if root.get_node(node_path) == root.get_node("Meta"):
			return track_idx 

	return -1

func get_meta_at_key_time(key_time:int) -> Array:
	var meta_track_idx = get_meta_track_idx()
	
	var animation:Animation = get_animation_()
	for key_idx in animation.track_get_key_count(meta_track_idx):
		var kt = animation.track_get_key_time(meta_track_idx, key_idx)
		if is_equal_approx(key_time, kt):
			var args = animation.method_track_get_params(meta_track_idx, key_idx)
			if args.size() > 0:
				return args[0]

	return []

func assure_functions_track_idx_() -> int:
	var animation:Animation = get_animation_()
	
	var root = animation_player_.get_node(animation_player_.root_node)
	
	for track_idx in animation.get_track_count(): 
		var node_path := animation.track_get_path(track_idx)
		if root.get_node_or_null(node_path) == root:
			return track_idx 

	return -1

func idk_():
	var functions_track_idx := assure_functions_track_idx_()

	var animation:Animation = get_animation_()

	for track_idx in animation.get_track_count():
		var node_path := animation.track_get_path(track_idx)

		if track_idx == functions_track_idx:
			continue

		var last_key_value = 0
		var last_key_time = 0

		for key_idx in animation.track_get_key_count(track_idx):
			var key_time = animation.track_get_key_time(track_idx, key_idx)
			var key_value = animation.bezier_track_get_key_value(track_idx, key_idx)
			if key_value != last_key_value:
				if (key_time - last_key_time) > 4.0:
					var meta = get_meta_at_key_time(key_time)
					animation.track_insert_key(functions_track_idx, max(last_key_time, 0.0), { "method" : "follow" , "args" : [node_path, last_key_time, key_time, last_key_value, key_value, meta] })
				else:
					var meta = get_meta_at_key_time(key_time)
					animation.track_insert_key(functions_track_idx, max(key_time - 0.5, 0.0), { "method" : "test" , "args" : [node_path, key_time, key_value, meta] })

			last_key_time = key_time
			last_key_value = key_value

		animation.track_set_enabled(track_idx, false)
