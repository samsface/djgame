extends MeshInstance3D
class_name FlashText

var tween_:Tween
var accuracy := 0.0

var hang_time_ := 0.0
var hang_time:float :
	set(value):
		set_hang_time(value)
var text :
	set(value):
		text = value
		mesh.text = text

var sub_text :
	set(value):
		sub_text = value
		$Sub.mesh.text = sub_text

var random_rotation_ := Vector3.ZERO

func _ready() -> void:
	random_rotation_ = (Vector3(randf(), randf(), randf()) * 2.0) - Vector3.ONE
	random_rotation_ *= 0.1

func _physics_process(delta: float) -> void:
	look_at(Bus.camera_service.get_head_position(), Vector3.DOWN)
	scale = Vector3(1, -1, -1)
	rotation += random_rotation_

func danger() -> void:
	mesh.material.albedo_color = Color("ff002c")
	pass

func ok() -> void:
	mesh.material.albedo_color = Color("00ef6f")
	pass

func set_hang_time(time:float) -> void:
	if hang_time == time:
		return

	hang_time_ = time

	var tween = create_tween()
	tween.tween_property(self, ^"transparency", 1.0, 0.1).set_delay(hang_time_)
	tween.finished.connect(queue_free)
