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
		
		#if not Bus.camera_service.recording:
		invalidate_()

var electric:Color = Color.TRANSPARENT :
	set(v):
		electric = v
		$Nob/Model/fader.electric = v

var dragging_ := false
var dragging_start_ := Vector2.ZERO
var mouse_over_ := false

@onready var path_follow_ = $Path3D/PathFollow3D
@onready var shadow_path_follow_ = $Path3D/PathFollow3D2

func _ready() -> void:
	path_follow = $Path/PathFollow
	set_physics_process(false)
	value = randf()
	
func buffer_change(time, v):
	value = v

func _physics_process(delta: float) -> void:
	if dragging_:
		if Input.is_action_just_released("click"):
			dragging_ = false
			$Nob/Model._grab_end()
			Bus.camera_service.cursor.pop(self)
			set_physics_process(false)

	if mouse_over_:
		if Input.is_action_just_pressed("click"):
			dragging_ = true
			$Nob/Model._grab_begin()
			Bus.camera_service.cursor.push(self, Cursor.Action.grab)
			dragging_start_ = get_window().get_mouse_position()
	
	if dragging_:
		var diff = Bus.input_service.relative.y * 0.001
		
		if diff == 0.0:
			return

		var new_value = value - diff

		value = clamp(new_value, 0.00, 1.0)

		Bus.camera_service.cursor.try_set_position(self, $Nob.global_position)

		if abs(diff) > 0.1:
			$Nob/Sparks.spark()

func _mouse_entered() -> void:
	print_debug(get_path())
	
	mouse_over_ = true
	set_physics_process(true)
	
	$Nob/Model.hover_begin()

func _mouse_exited() -> void:
	print_debug(get_path())
	
	mouse_over_ = false
	if not dragging_:
		set_physics_process(false)
		
		$Nob/Model.hover_end()

func get_path_follow() -> PathFollow3D:
	return $Path3D/PathFollow3D2

func invalidate_() -> void:
	if not path_follow_:
		return

	path_follow_.progress_ratio = value

	Bus.camera_service.cursor.try_set_position(self, $Nob.global_position)

	#Bus.camera_service.look_at_node(self.get_parent())

func get_guide_position_for_value(value:float) -> Vector3:
	var a = $Path3D.curve.get_baked_length()
	return $Path3D.to_global($Path3D.curve.sample_baked(value * a))

func update_path_follow_position_for_value(for_value:float) -> void:
	$Path.global_position = get_guide_position_for_value(for_value)

func get_nob_position() -> Vector3:
	return $Nob.global_position
