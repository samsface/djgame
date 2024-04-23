extends Node3D

var mouse_over_ := false
var grabbed_ := false

func _mouse_entered():
	mouse_over_ = true
	set_process_input(true)
	
func _mouse_exited():
	if not grabbed_:
		mouse_over_ = false
		set_process_input(false)
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		grabbed_ = true
	elif Input.is_action_just_released("click"):
		grabbed_ = false
		if not mouse_over_:
			_mouse_exited()

func _physics_process(delta: float) -> void:
	if grabbed_:
		$Jack.global_position = Bus.camera_service.cursor.position
