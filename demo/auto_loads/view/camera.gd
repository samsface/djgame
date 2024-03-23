extends Node3D

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
var level:Level
var guide_service:GuideService
var audio_service:AudioService

var stack_ := []
var head_pos_:Vector3

func logi(str:String) -> void:
	pass

func looking_at() -> void:
	pass

func _ready() -> void:
	cursor.push(self, Cursor.Action.point)

func rv(scale:float = 1.0) -> Vector3:
	return Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * scale

func shake(duration:float = 0.5, scale:float = 0.001) -> void:
	if shake_tween_ and shake_tween_.is_running():
		return

	shake_tween_ = create_tween()
	shake_tween_.set_speed_scale(0.2)
	for i in int(duration / 0.1):
		shake_tween_.tween_property(camera_, "position", position + rv(scale / (i+1)), 0.01)

func _physics_process(delta: float) -> void:
	if not stack_.is_empty():
		var r = camera_arm_.rotation
		camera_arm_.look_at(stack_[0][1].global_position)
		var rr = camera_arm_.rotation
		camera_arm_.rotation = r
		camera_arm_.rotation = lerp(r, rr, delta * 6.0)

		if stack_[0][1].has_method("get_view_position"):
			set_head_position_(stack_[0][1].get_view_position())

	
	if not cursor.is_owner(self):
		return
	
	cursor.update()

	var pos = cursor.position2D
	
	var from = camera_.project_ray_origin(pos)
	var to = from + camera_.project_ray_normal(pos) * 100
	var cursorPos = Plane(Vector3.UP, transform.origin.y).intersects_ray(from, to)
	if not cursorPos:
		return

	ray_cast_.position = camera_arm_.position
	ray_cast_.target_position = cursorPos - camera_arm_.position

	ray_cast_.force_raycast_update()

	if ray_cast_.is_colliding():
		$Debug.position = ray_cast_.get_collision_point()
		
		var next_hovering = ray_cast_.get_collider().get_parent()
		
		if hovering_ and next_hovering != hovering_:
			logi("MOUSE EXIT")
			hovering_._mouse_exited()
		
		var point = ray_cast_.get_collision_point()
		cursor.try_set_position(self, point + Vector3.UP * 0.002)
		
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

func set_head_position_(pos:Vector3) -> void:
	if head_pos_ != pos:
		head_pos_ = pos
		var tween := create_tween()
		tween.tween_property(camera_arm_, "position", pos, 0.5)

func get_head_position() -> Vector3:
	return camera_arm_.global_position

func look_at_node(node:Node3D) -> void:
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
	var looking_at = stack_.front()[1]
	
	while node.get_parent():
		if node == looking_at:
			return true

		node = node.get_parent()

	return false
