extends Control

signal pressed

@export var contact_name := "" :
	set(value):
		contact_name = value
		get_node("%ContactName").text = value
@export var contact_image:Texture :
	set(value):
		contact_image = value
		get_node("%Image").texture = value
@export var message := "" :
	set(value):
		message = value
		get_node("%Message").text = value
@export var time_stamp := 0.0 :
	set(value):
		time_stamp = value
		get_node("%TimeStamp").text = time_stamp_to_str_(value)

func _gui_input(event):
	if Input.is_action_just_pressed("click"):
		pressed.emit()

func time_stamp_to_str_(time_stamp:float) -> String:
	if GameTime.now - time_stamp < 5:
		call_deferred("refresh_timestamp_")
		return "now"

	return GameTime.format_time(time_stamp)

func refresh_timestamp_() -> void:
	$Timer.stop()
	$Timer.start(10)

func _timeout():
	get_node("%TimeStamp").text = time_stamp_to_str_(time_stamp)
