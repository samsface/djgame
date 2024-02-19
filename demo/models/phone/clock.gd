extends Node

signal minute_changed
signal hour_changed
signal day_changed

var now := 8 * 60 * 60
var now_o_clock:int
var time_callbacks_ := {}

var day:int :
	get:
		return int(now / 86400.0)

var hour:int :
	get:
		var total_seconds = int(now)
		var hours = total_seconds / 3600
		return hours % 24

var minute:int :
	get:
		var total_seconds = int(now)
		var minutes = (total_seconds % 3600) / 60
		return minutes

var speed := 500.0

func connect_to_time(time:Array[int], callback:Callable) -> void:
	var hour = time[0]
	var minute = time[1]
	
	if not time_callbacks_.has(hour):
		time_callbacks_[hour] = {}
		
	if not time_callbacks_[hour].has(minute):
		time_callbacks_[hour][minute] = []
	
	time_callbacks_[hour][minute].push_back(callback)

func _process(delta:float) -> void:
	#if Input.is_action_just_pressed("pause"):
	#	Engine.time_scale = 0.0

	Engine.time_scale = 1.0

	var day_ = day
	var hour_ = hour
	var minute_ = minute
	
	now += delta * speed

	if minute_ != minute:
		var hour_callback = time_callbacks_.get(hour)
		if hour_callback: 
			var minute_callback = hour_callback.get(minute)
			if minute_callback:
				for callback in time_callbacks_[hour][minute]:
					callback.call()

		minute_changed.emit()
		
		if hour_ != hour:
			hour_changed.emit()
			
			if day_ != day:
				day_changed.emit()

func format_time(seconds:float) -> String:
	var total_seconds = int(seconds)
	var minutes = (total_seconds % 3600) / 60
	return "%02d:%02d" % [hour, minutes]
