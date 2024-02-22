extends Node3D

var mouse_over_ := false
var grabbed_ := false

func _mouse_entered():
	mouse_over_ = true
	
func _mouse_exited():
	mouse_over_ = false
	
func _input(event: InputEvent) -> void:
	if not mouse_over_:
		return

	if Input.is_action_just_pressed("click"):
		grabbed_ = true
	elif Input.is_action_just_released("click"):
		grabbed_ = false
		
func _physics_process(delta: float) -> void:
	if grabbed_:
		$MeshInstance3D.atoms_[-1].global_position.x = Camera.cursor.position.x
		$MeshInstance3D.atoms_[-1].global_position.z = Camera.cursor.position.z
