extends Camera2D

var panning_ := false
var panning_start_position_ := Vector2.ZERO

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("pan"):
		pan_()
	elif Input.is_action_just_released("pan"):
		panning_ = false
	elif Input.is_action_just_pressed("zoom_in"):
		zoom += Vector2.ONE * 0.1
	elif Input.is_action_just_pressed("zoom_out"):
		zoom -= Vector2.ONE * 0.1

func pan_():
	if not panning_:
		panning_ = true
		panning_start_position_ = get_global_mouse_position()

	position += panning_start_position_ - get_global_mouse_position()
