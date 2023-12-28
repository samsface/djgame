extends Area2D
class_name PDCable

signal connection

@export var from:PDSlot
@export var to:PDSlot
@export var selectable:bool = true
@export var creating:bool = false

var just_created_ := true
var hovering_slot_

var selected_ := false
var dragging_ := false

func _input(event: InputEvent) -> void:
	if creating:
		if event.is_action_pressed("ui_cancel"):
			queue_free()
		if event.is_action_released("click"):
			if hovering_slot_:
				to = hovering_slot_
				creating = false
				invalidate_connections()
				connection.emit()
			else:
				queue_free()

func _physics_process(delta: float) -> void:
	#global_position = Vector2.ZERO
	
	var from_position = from.global_position + Vector2(16, 16)
	var to_position = get_global_mouse_position()
	
	if not creating:
		to_position = to.global_position + Vector2(16, 16)


	$Line2D.set_point_position(0, from_position)
	$Line2D.set_point_position(1, to_position)
	#$Polygon2D.polygon[0] = from_position
	#$Polygon2D.polygon[1] = to_position
	#$Polygon2D.polygon[2] = to_position + Vector2(-4, 4)
	#$Polygon2D.polygon[3] = from_position + Vector2(-4, 4)
	
	$CollisionShape2D.polygon[0] = from_position
	$CollisionShape2D.polygon[1] = to_position
	$CollisionShape2D.polygon[2] = to_position + Vector2(-10, 10)
	$CollisionShape2D.polygon[3] = from_position + Vector2(-10, 10)

	#if mouse_entered_ and Input.is_action_just_pressed("click"):
	#	SelectionBus.selection = [self]

func call_disconnect():
	if not from or not to:
		return

	from.parent.canvas.send_disconnect(from.parent.index, from.index, to.parent.index, to.index)

func call_connect():
	if not from or not to:
		return

	from.parent.canvas.create_connection(from.parent.index, from.index, to.parent.index, to.index)

	from.parent._connection(to)
	to.parent._connection(from)

	if not from.parent.visible:
		visible = false

	elif not to.parent.visible:
		visible = false

func invalidate_connections() -> void:
	call_disconnect()
	call_connect()

func _enter_tree() -> void:
	invalidate_connections()
	pass

func _exit_tree() -> void:
	call_disconnect()

func _mouse_entered() -> void:
	if creating:
		return

	SelectionBus.hovering = self
	invalidate_()

func _mouse_exited() -> void:
	if creating:
		return
		
	SelectionBus.remove_from_hover(self)
	invalidate_()
	
func _select():
	invalidate_()

func _unselect():
	invalidate_()

func _drag(pos:Vector2):
	pass

func _drag_end():
	pass

func invalidate_():
	if SelectionBus.is_selected(self):
		$Line2D.modulate = Color.WHITE
	elif SelectionBus.hovering == self:
		$Line2D.modulate = Color.ORANGE * 1.5
	else:
		$Line2D.modulate = Color.ORANGE

func _visibility_changed():
	if not visible:
		monitorable = false

func _area_entered(area: Area2D) -> void:
	if area.get_parent() == from:
		return

	hovering_slot_ = area.get_parent()
	hovering_slot_._cable_entered()

func _area_exited(area: Area2D) -> void:
	if hovering_slot_ != area:
		return

	hovering_slot_._cable_exited()
	hovering_slot_ = null
