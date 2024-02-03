extends Node3D

var tracks_ := {}
var beat_ := 0
var recording_ := false
var playing_ := false
var animation_player_:AnimationPlayer
var max_time_ := 0

func _ready() -> void:
	PureData.bind("s-clock-beat")
	PureData.bang.connect(_bang)
	
	await get_tree().process_frame
	
	animation_player_ = $AnimationPlayer
	animation_player_.play("test")

	max_time_ = get_last_data_time()

	$CanvasLayer/HSlider/ProgressBar.value = max_time_

func _bang(r):
	if r == "s-clock-beat":
		beat_ += 1
		if beat_ > max_time_:
			animation_player_.active = false
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

func record_() -> void:
	if recording_:
		recording_ = false
		$CanvasLayer/Label.text = ""
		dump_()
	else:
		recording_ = true
		$CanvasLayer/Label.text = "RECORDING"

func capture(node:Nob) -> void:
	if not recording_:
		return
		
	if beat_ < max_time_:
		return

	var node_path = NodePath(str(node.get_path()) + ":value")
		
	var animation:Animation = animation_player_.get_animation("test")
	var track_idx := animation.find_track(node_path, Animation.TYPE_VALUE)
	if track_idx == -1:
		track_idx = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_idx, node_path)
	
	animation.track_insert_key(track_idx, animation_player_.current_animation_position, node.value)

func dump_() -> void:
	var al:AnimationLibrary = animation_player_.libraries.values()[0]
	ResourceSaver.save(al, "res://junk/test.tres")

func get_last_data_time() -> int:
	var animation:Animation = animation_player_.get_animation("test")

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
		var animation:Animation = animation_player_.get_animation("test")
		animation_player_.active = true
		animation_player_.seek(value, true)
		animation_player_.active = false
