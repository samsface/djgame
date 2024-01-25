extends Nob
class_name NobSlider

signal value_changed(float)
signal impulse(Vector3, float)

@export var freedom:float = 0.02
@export var max_value:float = 127

var dragging_ := false
var dragging_start_ := Vector2.ZERO
var mouse_over_ := false

func _input(event: InputEvent) -> void:
	if dragging_:
		if event.is_action_released("click"):
			dragging_ = false
		
	if mouse_over_:
		if event.is_action_pressed("click"):
			dragging_ = true
			dragging_start_ = get_viewport().get_mouse_position()

func _physics_process(delta: float) -> void:
	if dragging_:
		var mp = get_viewport().get_mouse_position()
		var y = mp.y - dragging_start_.y
		dragging_start_ = mp
		
		var p = $Nob.position
		p.z += 0.00015 * y

		p.z = clamp(p.z, -freedom, freedom)

		$Nob.position = p
		
		var v = 1.0 - ((p.z / freedom) * 0.5 + 0.5)
		v *= max_value

		value_changed.emit(v)

		if abs(y) > 40.0 and is_equal_approx(abs(p.z), freedom):
			impulse.emit($Nob.position, y)

func _mouse_entered() -> void:
	mouse_over_ = true
	
func _mouse_exited() -> void:
	mouse_over_ = false
