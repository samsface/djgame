extends Control
class_name PDSpecial

var parent : 
	set(value):
		pass
	get:
		return get_parent().get_parent().get_parent().get_parent()
