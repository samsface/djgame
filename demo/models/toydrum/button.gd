extends Nob
class_name NobButton

signal value_changed(float)
signal impulse(Vector3, float)

@export var range:int = 2

var value : 
	set(v):
		value = v
		value_ = clamp(v, 0.0, 1.0)
		$Area3D/Button.light = light_color_()

var down_ := false
var mouse_over_ := false

var value_ := 0.0
var pulse_ := 0.0 :
	set(v):
		pulse_ = v
		$Area3D/Button.light = light_color_()

func _input(event: InputEvent) -> void:
	if down_:
		if event.is_action_released("click"):
			released()
		
	if mouse_over_:
		if event.is_action_pressed("click"):
			pressed()

func pressed() -> void:
	if down_:
		return

	down_ = true
	var tween = create_tween()
	tween.tween_property($Area3D, "position:y", -0.001, 0.01)

	value_ += 1
	value_ = int(value_) % range

	$Area3D/Button.light = light_color_()
	
	value_changed.emit(float(value_) / float(range))

func released() -> void:
	if not down_:
		return

	down_ = false

	var tween = create_tween()
	tween.tween_property($Area3D, "position:y", 0.000, 0.05)

func _mouse_entered() -> void:
	mouse_over_ = true
	
func _mouse_exited() -> void:
	mouse_over_ = false

func light_color_() -> float:
	return value_ + pulse_

func radio():
	var tween = create_tween()
	tween.tween_property(self, "pulse_", 0.5, 0.0)
	tween.tween_property(self, "pulse_", 0.0, 1.0).set_delay(0.1)


