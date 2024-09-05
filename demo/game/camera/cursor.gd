class_name Cursor
extends CanvasLayer

signal pushed
signal popped

enum Action {
	point,
	hover,
	grab,
	dot
}

var owner_stack_ := []

@onready var cursor_ = $Cursor2D
@onready var camera_ = get_node("../CameraArm/Camera3D")

@export var disabled := false :
	set(v):
		if v != disabled:
			disabled = v
			invalidate_disabled_()

func _ready() -> void:
	cursor_.position = get_viewport().size * 0.5

func get_position() -> Vector2:
	return cursor_.position

func is_owner(node:Node) -> bool:
	return owner_stack_.size() > 0 and owner_stack_.back()[0] == node

func push(node:Node, action:Action = Action.point) -> void:
	owner_stack_.push_back([node, action])
	cursor_.frame = action
	
	popped.emit()

func pop(node:Node) -> void:
	owner_stack_.pop_back()

	if owner_stack_.size() > 0:
		cursor_.frame = owner_stack_.back()[1]

	popped.emit()

func try_set_position(node:Node, pos:Vector3) -> void:
	if not is_owner(node):
		return

	cursor_.position = camera_.unproject_position(pos) 

func _physics_process(delta: float) -> void:
	if not is_owner(get_parent()):
		return

	if cursor_.frame == Action.dot:
		cursor_.position = get_viewport().size * 0.5
		cursor_.scale = Vector2.ONE
	else:
		cursor_.position += Bus.input_service.relative * 1.5
		cursor_.scale = Vector2(0.5, 0.5)

func invalidate_disabled_() -> void:
	if disabled:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		cursor_.position = get_viewport().size * 0.5
