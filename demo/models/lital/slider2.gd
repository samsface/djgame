extends Nob
class_name NobSlider

signal value_changed(float)
signal impulse(Vector3, float)

@export var value:float : 
	set(new_value):
		if new_value == value:
			return
			
		if reset_to_intended_value_tween_:
			reset_to_intended_value_tween_.kill()

		var old_value = value
		
		value = new_value
		
		value_changed.emit(value, old_value)
		
		if not Camera.recording:
			invalidate_()

var dragging_ := false
var dragging_start_ := Vector2.ZERO
var mouse_over_ := false

@onready var path_follow_ = $Path3D/PathFollow3D
@onready var shadow_path_follow_ = $Path3D/PathFollow3D2

func _ready() -> void:
	set_process_input(false)
	value = randf()

func _input(event: InputEvent) -> void:
	if dragging_:
		if event.is_action_released("click"):
			dragging_ = false
			$Nob/Model._grab_end()
			Camera.cursor.pop(self)

	if mouse_over_:
		if event.is_action_pressed("click"):
			dragging_ = true
			$Nob/Model._grab_begin()
			Camera.cursor.push(self, Cursor.Action.grab)
			dragging_start_ = get_window().get_mouse_position()

func _physics_process(delta: float) -> void:
	if dragging_:
		var diff = Camera.cursor.relative.y * 0.005
		if diff == 0.0:
			return

		Camera.cursor.relative = Vector2.ZERO
		
		var new_value = value - diff

		value = clamp(new_value, 0.05, 0.5)
		
		Camera.recorder.capture(self)
		
		Camera.cursor.try_set_position(self, $Nob.global_position)

func _mouse_entered() -> void:
	mouse_over_ = true
	set_process_input(true)
	
	$Nob/Model.hover_begin()

func _mouse_exited() -> void:
	mouse_over_ = false
	if not dragging_:
		set_process_input(false)
		
		$Nob/Model.hover_end()

func get_path_follow() -> PathFollow3D:
	return $Path3D/PathFollow3D2

func invalidate_() -> void:
	if not path_follow_:
		return

	path_follow_.progress_ratio = value

	Camera.cursor.try_set_position(self, $Nob.global_position + Vector3.UP * 0.002)
	
	
	
	Camera.look_at_node(self.get_parent())

func get_guide_position_for_value(value:float) -> Vector3:
	shadow_path_follow_.progress_ratio = value
	return shadow_path_follow_.global_position

func get_nob_position() -> Vector3:
	return $Nob.global_position
