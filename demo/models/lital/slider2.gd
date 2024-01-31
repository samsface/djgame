extends Nob
class_name NobSlider

signal value_changed(float)
signal impulse(Vector3, float)

@export var freedom:float = 0.02
@export var max_value:float = 127

var dragging_ := false
var dragging_start_ := Vector2.ZERO
var mouse_over_ := false

func _ready() -> void:
	set_process_input(false)

func _input(event: InputEvent) -> void:
	if dragging_:
		if event.is_action_released("click"):
			dragging_ = false
			Camera.cursor.pop(self)
			set_process_input(false)

	if mouse_over_:
		if event.is_action_pressed("click"):
			dragging_ = true
			Camera.cursor.push(self, Cursor.Action.grab)
			dragging_start_ = get_window().get_mouse_position()

func _physics_process(delta: float) -> void:
	if dragging_:
		var y = Camera.cursor.get_node("CanvasLayer/Sprite2D").x.y
		Camera.cursor.get_node("CanvasLayer/Sprite2D").x = Vector2.ZERO
		
		var p = $Nob.position
		p.z += 0.00015 * y

		p.z = clamp(p.z, -freedom, freedom)

		$Nob.position = p
		
		var v = 1.0 - ((p.z / freedom) * 0.5 + 0.5)
		v *= max_value

		value_changed.emit(v)

		if abs(y) > 40.0 and is_equal_approx(abs(p.z), freedom):
			impulse.emit($Nob.position, y)

		Camera.cursor.try_set_position(self, $Nob.global_position + Vector3.UP * 0.002)
		Camera.smooth_look_at(self.get_parent())

func _mouse_entered() -> void:
	mouse_over_ = true
	set_process_input(true)
	
	$Nob/slider2/slider.set_instance_shader_parameter("outline_color", Color.WHITE)
	
func _mouse_exited() -> void:
	mouse_over_ = false
	if not dragging_:
		set_process_input(false)
		$Nob/slider2/slider.set_instance_shader_parameter("outline_color", Color.TRANSPARENT)