extends RythmicAnimationPlayerControlItem
class_name PianoRollItemBang

@export var value:float = 1.0 : 
	set(v):
		value = v
		invalidate_value_()

@export var auto:bool : 
	set(v):
		auto = v
		invalidate_value_()

@export var hold:bool : 
	set(v):
		hold = v
		invalidate_value_()

@export var dilema_group:int : 
	set(v):
		dilema_group = v

@export var silent:bool : 
	set(v):
		silent = v
		invalidate_value_()

var tween_:Tween

func _ready():
	invalidate_value_()
	#item_rect_changed.connect(invalidate_value_)

func get_lookahead() -> int:
	return 10

func invalidate_value_() -> void:
	if silent:
		modulate = Color.CORNFLOWER_BLUE
	elif auto:
		modulate = Color.PURPLE
	else:
		modulate = Color.GREEN
		
	$ProgressBar.value = value

func begin() -> void:
	flash()

	var target_node = get_target_node()
	if target_node and target_node.has_method("bang"):
		var length_in_seconds = get_lookahead() * (Bus.audio_service.metro) * 0.001
		var duration_in_seconds = length * (Bus.audio_service.metro) * 0.001
		if not hold:
			duration_in_seconds = 0.0
		target_node.bang(time, length_in_seconds, value, auto, dilema_group, silent, duration_in_seconds)
