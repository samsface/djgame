extends Node3D

@onready var ray_cast_:RayCast3D = $RayCast3D
@onready var camera_arm_:Node3D = $CameraArm
@onready var camera_:Camera3D = $CameraArm/Camera3D
@onready var cursor = $Cursor

var shake_tween_:Tween
var looking_at_:Node3D
var looking_at_tween_:Tween
var hovering_

func _ready() -> void:
	camera_arm_.position.y = 0.15
	camera_arm_.position.z = 0.1

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
	if not cursor.is_owner(self):
		return
	
	$Cursor/CanvasLayer/Sprite2D.update()

	var pos = $Cursor/CanvasLayer/Sprite2D.position
	
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

func smooth_look_at(node, force = false) -> void:
	if not force:
		if looking_at_ == node:
			return
	
	if looking_at_tween_:
		looking_at_tween_.kill()
		
	looking_at_ = node
	
	var r = camera_arm_.rotation
	var p = camera_arm_.position
	
	camera_arm_.look_at(looking_at_.global_position)
	var t = camera_arm_.rotation
	camera_arm_.position = p
	camera_arm_.rotation = r

	looking_at_tween_ = create_tween()
	looking_at_tween_.set_speed_scale(1.2)
	looking_at_tween_.set_trans(Tween.TRANS_CUBIC)
	looking_at_tween_.set_ease(Tween.EASE_OUT)
	looking_at_tween_.set_parallel()
	#looking_at_tween_.tween_property(camera_arm_, "position:x", x, 0.6)
	looking_at_tween_.tween_property(camera_arm_, "rotation", t, 0.6)
	#tween_.tween_property($CameraArm, "fov", randf_range(50, 75), 0.6)
