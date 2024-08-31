extends Node3D
class_name CameraService

signal rumble

@onready var ray_cast_:RayCast3D = $RayCast3D
@onready var camera_arm_:Node3D = $CameraArm
@onready var camera_:Camera3D = $CameraArm/Camera3D
@onready var cursor = $Cursor

var shake_tween_:Tween
var looking_at_tween_:Tween
var hovering_

var recording := false
var recorder


var stack_ := []
var head_pos_:Vector3
@export var free_walk:bool :
	set(v):
		if not is_node_ready():
			await ready
		set_free_walk_(v)
		free_walk = v

@export var walk_height:float = 0.28
@export var no_walk:bool

@export var look_x_range := Vector2(-90, 90)
@export var look_y_range := Vector2(-360, 360)
@export var look_speed := 0.8
	
@export var noclip:bool :
	set(v):
		noclip = v
		if not noclip:
			rotation = Vector3.ZERO
			position = Vector3.ZERO
	
func logi(str:String) -> void:
	pass

func looking_at() -> void:
	pass

func _ready() -> void:
	Bus.camera_service = self
	cursor.push(self, Cursor.Action.point)

func rv(scale:float = 1.0) -> Vector3:
	return Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * scale

func shake(duration:float = 0.5, scale:float = 0.001) -> void:
	if shake_tween_ and shake_tween_.is_running():
		shake_tween_.kill()	

	shake_tween_ = create_tween()
	shake_tween_.set_speed_scale(0.2)
	shake_tween_.tween_interval(Bus.audio_service.latency * 0.2)
	
	for i in int(duration / 0.1):
		shake_tween_.tween_property(camera_, "position", position + rv(scale / (i+1)), 0.01)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_free_walk"):
		set_free_walk_(not free_walk)
	elif event.is_action_pressed("toggle_noclip"):
		noclip = not noclip

func set_free_walk_(value:bool) -> void:
	if free_walk == value:
		return

	if free_walk:
		cursor.pop($Cursor)
	
	else:
		cursor.push($Cursor, Cursor.Action.dot)

func _physics_process(delta: float) -> void:
	if noclip:
		if Bus.camera_service.cursor.disabled:
			return
		
		var speed := 0.01
		var rotation_sped := 0.1
		if Input.is_key_pressed(KEY_ALT):
			speed = 0.001
			rotation_sped = 0.1
		
		camera_arm_.position = Vector3.ZERO
		camera_arm_.rotation.y = 0
		camera_arm_.rotation.z = 0
		camera_.position = Vector3.ZERO
		camera_.rotation = Vector3.ZERO
		rotate_y(deg_to_rad(-Bus.input_service.relative.x * 8.0 * rotation_sped))
		camera_arm_.rotate_x(deg_to_rad(-Bus.input_service.relative.y * 8.0 * rotation_sped))
		camera_arm_.rotation.x = clamp(camera_arm_.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		camera_arm_.rotation.z = 0
		
		var move := Input.get_vector("move_left", "move_right", "move_forward", "move_backward") * 0.1
		var y = 0
		if move.y > 0:
			y = -1.0
		elif move.y < 0:
			y = 1.0
		
		var direction = (transform.basis * Vector3(move.x, 0, move.y)).normalized()

		position.y += camera_arm_.rotation.x * y * speed
		position.x += direction.x * speed
		position.z += direction.z * speed

		ray_cast_.position = Vector3.ZERO
		ray_cast_.global_rotation = camera_arm_.global_rotation
		ray_cast_.target_position = Vector3.FORWARD * 10000
		#ray_cast_.target_position = cursorPos - camera_arm_.position

		ray_cast_at_()
		
		return

	elif free_walk:
		camera_arm_.position = Vector3.ZERO
		camera_arm_.rotation.y = 0
		camera_arm_.rotation.z = 0
		camera_.position = Vector3.ZERO
		camera_.rotation = Vector3.ZERO
		rotate_y(deg_to_rad(-Bus.input_service.relative.x * look_speed))
		rotation.y = clamp(rotation.y, deg_to_rad(look_y_range.x), deg_to_rad(look_y_range.y))
		
		camera_arm_.rotate_x(deg_to_rad(-Bus.input_service.relative.y * look_speed))
		camera_arm_.rotation.x = clamp(camera_arm_.rotation.x, deg_to_rad(look_x_range.x), deg_to_rad(look_x_range.y))
		camera_arm_.rotation.z = 0
		
		var move := Input.get_vector("move_left", "move_right", "move_forward", "move_backward") * 0.1
		if no_walk:
			move *= 0.0
		
		var direction = (transform.basis * Vector3(move.x, 0, move.y)).normalized()

		position.y = walk_height
		position.x += direction.x * 0.05
		position.z += direction.z * 0.05

		ray_cast_.position = Vector3.ZERO
		ray_cast_.global_rotation = camera_arm_.global_rotation
		ray_cast_.target_position = Vector3.FORWARD * 10000
		#ray_cast_.target_position = cursorPos - camera_arm_.position

		ray_cast_at_()

		return

	#rotation = Vector3.ZEROradio
	#position = Vector3.ZERO
	
	if not cursor.is_owner(self):
		return
	
	cursor.update()

	var pos = cursor.position2D
	
	var from = camera_.project_ray_origin(pos)
	var to = from + camera_.project_local_ray_normal(pos) * 100.0
	ray_cast_.rotation = Vector3.ZERO
	ray_cast_.position = camera_arm_.position
	ray_cast_.target_position = to 
	
	ray_cast_at_()

func ray_cast_at_() -> void:
	ray_cast_.force_raycast_update()

	if ray_cast_.is_colliding():
		var next_hovering = ray_cast_.get_collider().get_parent()
		
		if hovering_ and next_hovering != hovering_:

			logi("MOUSE EXIT")
			if is_instance_valid(hovering_):
				hovering_._mouse_exited()

		var point = ray_cast_.get_collision_point()
		#cursor.try_set_position(self, point)
		
		#print(next_hovering)
		
		if hovering_ == next_hovering:
			pass
		elif next_hovering.has_method("_mouse_entered"):
			logi("MOUSE ENTER")
			hovering_ = next_hovering
			hovering_._mouse_entered()
		else:
			logi("MOUSE ENTER NOTING")
			hovering_ = null
	elif hovering_:
		if is_instance_valid(hovering_):
			hovering_._mouse_exited()
			hovering_ = null

func set_head_position_(pos:Vector3, pos2:Vector3) -> void:
	if head_pos_ != pos:
		head_pos_ = pos
		var tween := create_tween()
		tween.set_parallel()
		tween.tween_property(camera_arm_, "position", pos, 0.5)
		
		var d := auto_focus(pos, pos2)
		
		tween.tween_property(camera_.attributes, "dof_blur_near_transition", d * 0.99, 1.0)
		tween.tween_property(camera_.attributes, "dof_blur_near_distance", d, 1.0)

func auto_focus(from:Vector3, to:Vector3) -> float:
	return sqrt(from.distance_to(to)) * 0.33

func get_head_position() -> Vector3:
	return camera_arm_.global_position

@export var dolly:Transform3D :
	set(v):
		dolly = v
		camera_arm_.transform = Transform3D()
		camera_.transform = Transform3D()
		transform = dolly

func looky(pos:Vector3, rot:Vector3, length := 0.6) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_parallel()
	tween.tween_property(camera_arm_, "position", pos, length)
	tween.tween_property(camera_arm_, "rotation", rot, length)

func look_at_node(node:Node3D) -> void:
	if not node:
		return

	if not stack_.is_empty():
		for i in stack_.size():
			if stack_[i][2] == 1:
				stack_[i][1] = node
	else:
		push_look_at(node, 1, 1)

func push_look_at(node, priority:int, tag:int) -> void:
	if not stack_.is_empty():
		for i in stack_.size():
			if stack_[i][0] > priority:
				stack_.insert(i, [priority, node, tag])
				return
	else:
		stack_.push_back([priority, node, tag])

func pop_look_at(node) -> void:
	for i in stack_.size():
		if stack_[i][1] == node:
			stack_.remove_at(i)
			return

func shift():
	var tween = create_tween()
	pass

func is_looking_at_parent(node:Node):
	if stack_.is_empty():
		return false

	var looking_at = stack_.front()[1]
	
	while node.get_parent():
		if node == looking_at:
			return true

		node = node.get_parent()

	return false

func tweak() -> void:
	camera_.rotation_degrees.z = randf_range(3.0, 5.0)
	get_tree().create_timer(randf_range(0.1, 0.3)).timeout.connect(func():  camera_.rotation_degrees.z = 0)
