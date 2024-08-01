extends RythmicAnimationPlayerControlItem

enum TransitionType {
	TOGGLE,
	LINEAR
}

enum EaseType {
	EASE_IN,
	EASE_OUT
}

@export var property:String : 
	set(v):
		property = v
		invalidate_value_()

@export var from_value:float : 
	set(v):
		from_value = v
		invalidate_value_()

@export var to_value:float : 
	set(v):
		to_value = v
		invalidate_value_()

@export var tween_type:TransitionType :
	set(v):
		tween_type = v
		invalidate_value_()

@export var tween_ease:Tween.EaseType :
	set(v):
		tween_ease = v
		invalidate_value_()

var value_before_begin_

func _ready():
	invalidate_value_()

func invalidate_value_() -> void:
	self_modulate = Color.DARK_SLATE_GRAY
	
	$Label.text = "%s" % [to_value]

func infer_type(value):
	if typeof(value_before_begin_) == TYPE_BOOL:
		return bool(value)
	else:
		return value

func begin():
	flash()
	
	var target_node = get_target_node()
	if target_node:
		var property_path := get_target_property_path()
		if not property_path.is_empty():
			value_before_begin_ = target_node.get_indexed(property_path)
			if tween_type == TransitionType.TOGGLE:
				target_node.set_indexed(property_path, infer_type(from_value))
			else:
				var tween = target_node.create_tween()
				tween.tween_property(target_node, property_path, infer_type(to_value), length * (Bus.audio_service.metro) * 0.001).from(from_value)

func end():
	if tween_type == TransitionType.TOGGLE:
		var target_node = get_target_node()
		if target_node:
			var property_path := get_target_property_path()
			if not property_path.is_empty():
					target_node.set_indexed(property_path, infer_type(to_value))
