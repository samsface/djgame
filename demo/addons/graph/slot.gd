extends Control
class_name GraphControlSlot

signal button_down

var parent :
	set(value):
		pass
	get:
		return get_parent().get_parent().get_parent().get_parent()

@export var index := 0
@export var is_output := false
@export var allowed_connections_mask := 1
@export var cable:Node : 
	set(value):
		cable = value
		set_cable_(value)

var tween_

func set_cable_(value:Node) -> void:
	pass

func _ready() -> void:
	modulate = Color.PURPLE

	$PanelContainer.material.set_shader_parameter("up", is_output)
	
	#if not is_output:
	#	$Area2D/CollisionShape2D.position.y = $Area2D/Marker2D.position.y

func _cable_entered():
	modulate = Color.PURPLE * 1.5

func _cable_exited():
	modulate = Color.PURPLE

func _mouse_entered() -> void:
	z_index = 5
	modulate = Color.PURPLE * 1.5
	
	if tween_:
			tween_.kill()
	tween_ = create_tween()
	tween_.tween_property($PanelContainer.material, "shader_parameter/l", 1.0, 0.02)
	tween_.set_ease(Tween.EASE_OUT)
	tween_.set_trans(Tween.TRANS_CIRC)

func _mouse_exited() -> void:
	z_index = 0
	modulate = Color.PURPLE
	
	if tween_:
		tween_.kill()
	tween_ = create_tween()
	tween_.tween_property($PanelContainer.material, "shader_parameter/l", 0.0, 0.05)
	tween_.set_ease(Tween.EASE_OUT)
	tween_.set_trans(Tween.TRANS_CIRC)

func _visibility_changed() -> void:
	pass
