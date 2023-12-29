extends Control
class_name PDSlot

signal button_down

var parent :
	set(value):
		pass
	get:
		return get_parent().get_parent().get_parent().get_parent().get_parent()

@export var index := 0
@export var is_output := false
@export var allowed_connections_mask := 1
@export var cable:Node : 
	set(value):
		cable = value
		set_cable_(value)

func set_cable_(value:Node) -> void:
	pass

func _ready() -> void:
	modulate = Color.PURPLE

func _input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		button_down.emit()

func _cable_entered():
	modulate = Color.PURPLE * 1.5

func _cable_exited():
	modulate = Color.PURPLE

func _mouse_entered() -> void:
	modulate = Color.PURPLE * 1.5

func _mouse_exited() -> void:
	modulate = Color.PURPLE
