@tool
extends Control
class_name NegativeScrollContainer

@export var scroll_horizontal:int :
	set(v):
		scroll_horizontal = v
		if get_child_count() > 0:
			get_child(0).position.x = scroll_horizontal
			get_child(0).position.y = scroll_vertical

@export var scroll_vertical:int :
	set(v):
		scroll_vertical = v
		if get_child_count() > 0:
			get_child(0).position.x = scroll_horizontal
			get_child(0).position.y = scroll_vertical
			prints(scroll_vertical, get_child(0).position.y)

func auto_scroll(delta) -> bool:
	var mpx = get_local_mouse_position().x
	var d = mpx - size.x

	if d > 0:
		scroll_horizontal -= d * delta * 10.0
		return true
		
	elif mpx < 0:
		scroll_horizontal -= mpx * delta * 10.0
		return true

	return false
