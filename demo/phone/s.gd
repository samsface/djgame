extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			fov += 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			fov -= 1
	
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("click"):
			$"../phone".rotation.z += event.relative.x * 0.01
	
