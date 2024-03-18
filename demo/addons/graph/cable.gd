extends Area2D
class_name GraphControlCable

@export var from:GraphControlSlot
@export var to:GraphControlSlot
@export var selectable:bool = true
@export var creating:bool = false

var fallback_from_position := Vector2.ZERO
var fallback_to_position := Vector2.ZERO

var text :
	set(value):
		pass
	get:
		return "connect %s %s %s %s" % [from.parent.index, from.index, to.parent.index, to.index]

var creating_slot :
	set(value):
		pass
	get: return from if from else to

var just_created_ := true

var selected_ := false
var dragging_ := false

func  _ready() -> void:
	name = "cable"

func connect_(slot):
	if to:
		from = slot
	else:
		to = slot

	creating = false
	invalidate_connections()

func _physics_process(delta: float) -> void:
	var from_position := Vector2.ZERO
	var to_position := Vector2.ZERO

	if from:
		from_position = from.global_position + Vector2(10, 18)
	else:
		from_position = fallback_from_position

	if to:
		to_position = to.global_position + Vector2(10, 2)
	else:
		to_position = fallback_to_position

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
	invalidate_()

func _exit_tree() -> void:
	call_disconnect()
	SelectionBus.remove_from_all(self)

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

func _move():
	pass

func _move_end():
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
	pass

func _area_exited(area: Area2D) -> void:
	pass

func auto_connect(object) -> void:
	pass

func _pre_save() -> void:
	pass

func _play_mode_begin() -> void:
	pass

func _play_mode_end() -> void:
	pass
