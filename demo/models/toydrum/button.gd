@tool
extends Nob
class_name NobButton

signal value_changed(float)
signal value_will_change
signal impulse(Vector3, float)

@export var action:InputEventAction

@export var label:String : 
	set(v):
		label = v
		if not is_node_ready():
			await ready
		%Label.label = label

@export var label_style:LabelStyle :
	set(v):
		label_style = v
		if not is_node_ready():
			await ready
		%Label.label_style = label_style
		
@export var albedo:Color :
	set(v):
		albedo = v
		if not is_node_ready():
			await ready
		%Button.albedo = albedo

@export_range(0.0, 1.0) var wear:float :
	set(v):
		wear = v
		if not is_node_ready():
			await ready
		%Button.wear = wear

@export var electric:Color :
	set(v):
		electric = v
		if not is_node_ready():
			await ready
		%Button.electric = electric
		
@export var wear_albedo:Color :
	set(v):
		wear_albedo = v
		if not is_node_ready():
			await ready
		%Button.wear_albedo = wear_albedo

@export var press_distance:float

@onready var top = $Top

var value : 
	set(v):
		if v == value_:
			return

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
	path_follow = $Path/PathFollow

func buffer_change(time, value):
	value_will_change.emit(time, value)

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if down_:
		if event.is_action_released("click"):
			released()
		elif action and event.is_action_released(action.action):
			released()
		
	elif mouse_over_:
		if event.is_action_pressed("click"):
			pressed()
		elif action and event.is_action_pressed(action.action):
			pressed()

	elif action and action.action and event.is_action_pressed(action.action):
		pressed()

func pressed() -> void:
	if down_:
		return

	down_ = true
	var tween = create_tween()
	tween.tween_property($Nob, "position:y", -press_distance, 0.01)

	if lock:
		return

	#if guide:
	#	if guide.distance < 1:
	#		return

	value_ = 1.0

	#$Nob/Model/Button.light = light_color_()
	#if has_node("Sound"):
	#	$Sound.play()
	
	value_changed.emit(value_)
		
	#Bus.camera_service.cursor.push(self, Cursor.Action.grab)
	#Bus.camera_service.cursor.try_set_position(self, global_position)
	#Bus.camera_service.look_at_node(self.get_parent())



func released() -> void:
	if not down_:
		return

	down_ = false
	value_ = 0
	

	var tween = create_tween()
	tween.tween_property($Nob, "position:y", 0, 0.05)
	
	#Bus.camera_service.cursor.pop(self)

func _mouse_entered() -> void:
	mouse_over_ = true
	set_process(true)
	
	$Nob/Model.hover_begin()
	
func _mouse_exited() -> void:
	mouse_over_ = false
	if not down_:
		set_process(false)
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

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	return
	
	if Input.is_action_just_pressed("click"):
		call_deferred("pressed")
	elif Input.is_action_just_released("click"):
		call_deferred("released")
