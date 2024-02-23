extends VerletBody

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
		atoms_[1].global_position.x = Camera.cursor.position.x
		atoms_[1].global_position.y = 0.09
		atoms_[1].global_position.z = Camera.cursor.position.z

	var dr = atoms_[1].global_position.direction_to(atoms_[0].global_position)
	var di = atoms_[1].global_position.distance_to(atoms_[0].global_position)

	$jack.global_position = atoms_[1].global_position
	$jack.look_at(atoms_[0].global_position)
	$jack.global_position += dr * di * 0.5
