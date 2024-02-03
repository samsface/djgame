class_name Cursor
extends Sprite3D

signal pushed
signal popped

enum Action {
	point,
	hover,
	grab
}

var relative:Vector2 :
	set(v):
		relative = v
	get:
		return relative

var position2D:Vector2

var owner_stack_ := []
var next_position_ := Vector3.ZERO

@onready var cursor_ = $DebugCursorCanvasLayer/DebugCursor

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	position2D = get_window().get_visible_rect().size / 2

func is_owner(node:Node) -> bool:
	return owner_stack_.size() > 0 and owner_stack_.back()[0] == node

func push(node:Node, action:Action = Action.point) -> void:
	owner_stack_.push_back([node, action])
	frame = action
	
	popped.emit()

func pop(node:Node) -> void:
	owner_stack_.pop_back()

	if owner_stack_.size() > 0:
		frame = owner_stack_.back()[1]

	Camera.cursor.position2D = get_node("../CameraArm/Camera3D").unproject_position(position)
	next_position_ = position

	popped.emit()

func try_set_position(node:Node, pos:Vector3) -> void:
	if not is_owner(node):
		return

	next_position_ = pos

func _process(delta: float) -> void:
	position = next_position_

var x := Vector2.ZERO

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		relative = event.relative
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func update() -> void:
	position2D += relative * 1.5
	cursor_.position = position2D
	relative = Vector2.ZERO
