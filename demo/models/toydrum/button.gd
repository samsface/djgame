extends Nob
class_name NobButton

signal value_changed(float)
signal impulse(Vector3, float)

@export var range:int = 2

var value : 
	set(v):
		value = v
		value_ = clamp(v, 0.0, 1.0)
		$Nob/Model/Button.light = light_color_()
	get:
		return value_

var down_ := false
var mouse_over_ := false

var value_ := 0.0
var pulse_ := 0.0 :
	set(v):
		pulse_ = v
		$Nob/Model/Button.light = light_color_()

func _ready() -> void:
	set_process_input(false)

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
	tween.tween_property($Nob, "position:y", -0.001, 0.01)

	value_ += 1
	value_ = int(value_) % range

	$Nob/Model/Button.light = light_color_()
	
	value_changed.emit(float(value_) / float(range))
	
	Camera.cursor.push(self, Cursor.Action.grab)
	Camera.cursor.try_set_position(self, global_position + Vector3.UP * 0.002)
	Camera.look_at_node(self.get_parent())
	#Camera.set_head_position(self.get_parent().get_view_position())

func released() -> void:
	if not down_:
		return

	down_ = false

	var tween = create_tween()
	tween.tween_property($Nob, "position:y", 0.000, 0.05)
	
	Camera.cursor.pop(self)

func _mouse_entered() -> void:
	mouse_over_ = true
	set_process_input(true)
	
	$Nob/Model.hover_begin()
	
func _mouse_exited() -> void:
	mouse_over_ = false
	if not down_:
		set_process_input(false)
		$Nob/Model.hover_end()

func light_color_() -> float:
	return value_ + pulse_

func radio():
	var tween = create_tween()
	tween.tween_property(self, "pulse_", 0.5, 0.0)
	tween.tween_property(self, "pulse_", 0.0, 1.0).set_delay(0.1)
