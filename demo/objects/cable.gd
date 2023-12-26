extends Area2D
class_name PDCable

@export var from:Node
@export var to:Node
@export var selectable:bool = true

var just_created_ := true
var selected_ := false
var dragging_ := false

func _ready() -> void:
	invalidate_()

func _physics_process(delta: float) -> void:
	var from_position = from.global_position
	var to_position = get_global_mouse_position()
	
	if to:
		to_position = to.global_position

	$Polygon2D.polygon[0] = from_position
	$Polygon2D.polygon[1] = to_position
	$Polygon2D.polygon[2] = to_position + Vector2(0, 10)
	$Polygon2D.polygon[3] = from_position + Vector2(0, 10)
	
	$CollisionShape2D.polygon[0] = from_position
	$CollisionShape2D.polygon[1] = to_position
	$CollisionShape2D.polygon[2] = to_position + Vector2(0, 10)
	$CollisionShape2D.polygon[3] = from_position + Vector2(0, 10)

	#if mouse_entered_ and Input.is_action_just_pressed("click"):
	#	SelectionBus.selection = [self]

func invalidate():
	pass

func call_disconnect():
	if not from or not to:
		return

	PureData.send_disconnect(from.parent.canvas, from.parent.index, from.index, to.parent.index, to.index)

func call_connect():
	if not from or not to:
		return
	
	PureData.create_connection(from.parent.canvas, from.parent.index, from.index, to.parent.index, to.index)

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
	call_connect()

func _exit_tree() -> void:
	call_disconnect()
	SelectionBus.remove_from_selection(self)
	SelectionBus.remove_from_hover(self)

func _mouse_entered() -> void:
	SelectionBus.hovering = self
	invalidate_()

func _mouse_exited() -> void:
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
		$Polygon2D.color = Color.WHITE
	elif SelectionBus.hovering == self:
		$Polygon2D.color = Color.AQUA
	else:
		$Polygon2D.color = Color.DARK_SLATE_GRAY

func _visibility_changed():
	if not visible:
		monitorable = false
