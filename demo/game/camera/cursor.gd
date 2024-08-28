class_name Cursor
extends Node3D

signal pushed
signal popped

enum Action {
	point,
	hover,
	grab,
	dot
}

var relative:Vector2 :
	set(v):
		relative = v
	get:
		return relative

var position2D:Vector2

var owner_stack_ := []
var next_position_ := Vector3.ZERO

@onready var cursor_ = $CanvasLayer/Cursor2D
@onready var camera_ = get_node("../CameraArm/Camera3D")

@export var disabled := false :
	set(v):
		if v != disabled:
			disabled = v
			invalidate_disabled_()

func _ready() -> void:
	position2D = get_window().get_visible_rect().size / 2
	invalidate_disabled_()

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

	Bus.camera_service.cursor.position2D = camera_.unproject_position(position)
	next_position_ = position

	popped.emit()

func try_set_position(node:Node, pos:Vector3) -> void:
	if not is_owner(node):
		return

	next_position_ = pos

func distance_to_camera_(distance):
	distance = min(distance, 0.5) / 0.5
	distance = max(1.0 - distance, 0.4)

	return Vector2(0.25, 0.25) * distance * 1.5

func _physics_process(delta: float) -> void:
	if cursor_.frame == Action.dot:
		cursor_.position = get_viewport().size * 0.5
		cursor_.scale = Vector2.ONE
	else:
		position = next_position_
		cursor_.position = position2D#camera_.unproject_position(position) 
		#position2D = cursor_.position
		cursor_.scale = Vector2(0.5, 0.5)
	
func invalidate_disabled_() -> void:
	if not disabled:
		reset()#a#a
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func reset() -> void:
	#dafInput.mouse_mode = Input.MOUSE_MODE_CAPTURED
	position2D = get_viewport().size * 0.5

func update() -> void:

	if disabled:
		return

	# this should go into the input service
	position2D += Bus.input_service.relative * 1.5

	#var view_port_rect := get_viewport().get_visible_rect()
	#position2D = position2D.clamp(Vector2.ZERO, view_port_rect.size)
