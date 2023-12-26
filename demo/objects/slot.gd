extends Button
class_name PDSlot

var parent :
	set(value):
		pass
	get:
		return get_parent().get_parent().get_parent().get_parent().get_parent()

@export var index := 0
@export var cable:Node : 
	set(value):
		cable = value
		set_cable_(value)


func set_cable_(value:Node) -> void:
	pass
