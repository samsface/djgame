extends Button

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
@export var unread_count := 0 :
	set(value):
		unread_count = value
		get_node("%UnreadCount").visible = unread_count > 0
		get_node("%UnreadCount").text = str(value)
		
		get_node("%Message").modulate = Color.WHITE if unread_count > 0 else Color.DARK_GRAY
		get_node("%TimeStamp").modulate = Color.WHITE if unread_count > 0 else Color.DARK_GRAY

func time_stamp_to_str_(time_stamp:float) -> String:
	if GameTime.now - time_stamp < 10:
		return "Just Now"
		
	return GameTime.format_time(time_stamp)

func _timeout():
	get_node("%TimeStamp").text = time_stamp_to_str_(time_stamp)
