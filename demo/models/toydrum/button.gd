extends Nob
class_name NobButton

signal value_changed(float)
signal impulse(Vector3, float)

var value : 
	set(v):
		if v == value_:
			return

		value_ = clamp(v, 0.0, 1.0)
		$Nob/Model/Button.light = light_color_()
		value_changed.emit(value_)
	get:
		return value_

var down_ := false
var mouse_over_ := false

var value_ := 0.0
var pulse_ := 0.0 :
	set(v):
		pulse_ = v
		$Nob/Model/Button.light = light_color_()

var electric:Color = Color.TRANSPARENT :
	set(v):
		electric = v
		$Nob/Model/Button.electric = v

@onready var path_follow = $Path/PathFollow
@onready var remote_transform = $Path/PathFollow/RemoteTransform

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

	value_ = intended_value# 1.0 - value

	$Nob/Model/Button.light = light_color_()
	if has_node("Sound"):
		$Sound.play()
	
	value_changed.emit(value_)
	
	Camera.cursor.push(self, Cursor.Action.grab)
	Camera.cursor.try_set_position(self, global_position + Vector3.UP * 0.002)
	#Camera.look_at_node(self.get_parent())

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
	tween.tween_property(self, "pulse_", 0.0, 0.0).set_delay(0.1)
	
	if value > 0.0:
		tween.tween_property(self, "scale", Vector3.ONE * 1.2, 0.0)
		tween.tween_property(self, "scale", Vector3.ONE, 0.1).set_delay(0.1)
