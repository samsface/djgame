extends Node3D

@onready var ray_cast_:RayCast3D = $RayCast3D
@onready var camera_arm_:Node3D = $CameraArm
@onready var camera_:Camera3D = $CameraArm/Camera3D
@onready var cursor = $Cursor

var shake_tween_:Tween
var looking_at_:Node3D
var looking_at_tween_:Tween
var hovering_

var recording := false
var recorder

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

func _process(delta: float) -> void:
	if looking_at_:
		var r = camera_arm_.rotation
		camera_arm_.look_at(looking_at_.global_position)
		var rr = camera_arm_.rotation
		camera_arm_.rotation = r
		camera_arm_.rotation = lerp(r, rr, delta * 6.0)

func _physics_process(delta: float) -> void:
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
		if hovering_:
			hovering_._mouse_exited()
		
		var point = ray_cast_.get_collision_point()
		cursor.try_set_position(self, point + Vector3.UP * 0.002)

		if ray_cast_.get_collider().get_parent() is Nob:
			hovering_ = ray_cast_.get_collider().get_parent()
			hovering_._mouse_entered()

func set_head_position(pos:Vector3) -> void:
	var tween := create_tween()
	tween.tween_property(camera_arm_, ^"position", pos, 0.5)


func get_head_position() -> Vector3:
	return camera_arm_.position

func smooth_look_at(node, force = false) -> void:
	looking_at_ = node

func shift():
	var tween = create_tween()
	pass
