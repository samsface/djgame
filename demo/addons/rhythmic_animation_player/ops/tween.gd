extends RythmicAnimationPlayerControlItem

enum TransitionType {
	TOGGLE,
	LINEAR,
	SINE,
	QUINT,
	QUART,
	QUAD,
	EXPO,
	ELASTIC,
	CUBIC,
	CIRC,
	BOUNCE,
	BACK,
	SPRING
}

enum EaseType {
	EASE_IN,
	EASE_OUT,
	EASE_IN_OUT,
	EASTE_OUT_IN,
}

@export var property:String : 
	set(v):
		property = v
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

@export var enable_from:bool : 
	set(v):
		enable_from = v
		invalidate_value_()

var tween_:Tween
var value_
var from_

func _ready():
	invalidate_value_()

func _set(property:StringName, value):
	if property == "test" or property == "value":
		value_ = value
	elif property == "from":
		from_ = value

func _get(property:StringName):
	if property == "test" or property == "value":
		var x = get_target_node_property_value_()
		if typeof(value_) == typeof(x):
			return value_
		else:
			return 0
	elif property == "from":
		var x = get_target_node_property_value_()
		if typeof(from_) == typeof(x):
			return from_
			Tween.TRANS_BACK
		else:
			return 0 

func _get_property_list():
	var property = get_property_or_null_()
	if property == null:
		return []

	var properties := []
	
	property.usage |= PROPERTY_USAGE_SCRIPT_VARIABLE
	
	if enable_from:
		var from = property.duplicate()
		from.name = "from"
		properties.push_back(from)
	
	property.name = "value"
	properties.push_back(property)

	return properties

func invalidate_value_() -> void:
	self_modulate = Color.DARK_SLATE_GRAY

func get_target_node_property_value_():
	var target_node = get_target_node()
	if target_node:
		var property_path := get_target_property_path()
		if not property_path.is_empty():
			return target_node.get_indexed(property_path)

	return null

func get_property_or_null_():
	var target_node = get_target_node()
	if not target_node:
		return
		
	var property_path := get_target_property_path()
	if property_path.is_empty():
		return

	for property in target_node.get_property_list():
		if property.name == property_path.get_subname(0):
			return property
	
	return null

func subtract_variant(a, b):
	match typeof(value_):
		TYPE_TRANSFORM3D:
			return b.affine_inverse() * a;
		TYPE_BOOL:
			return b

	return a - b

func interprolate(from, t):
	if not tween_:
		tween_ = create_tween()
	
	if from == null:
		match typeof(value_):
			TYPE_TRANSFORM3D:
				from = Transform3D()
			TYPE_INT:
				from = 0
			TYPE_FLOAT:
				from = 0.0
			TYPE_BOOL:
				from = false
			TYPE_VECTOR3:
				from = Vector3.ZERO

	var target_node = get_target_node()
	if target_node:
		var property_path := get_target_property_path()
		if not property_path.is_empty():

			var elapsed_time = ((t - time) / float(length))

			if elapsed_time >= 1.0:	
				target_node.set_indexed(property_path, value_)
			elif elapsed_time <= 0.0:
				target_node.set_indexed(property_path, from)
			else:
				if tween_type == TransitionType.TOGGLE:
					if enable_from:
						target_node.set_indexed(property_path, from_)
					else:
						target_node.set_indexed(property_path, value_)
				else:
					var new_value = tween_.interpolate_value(from, subtract_variant(value_, from), elapsed_time, 1.0, tween_type - 1, tween_ease)
					target_node.set_indexed(property_path, new_value)

func begin():
	flash()
	
	var target_node = get_target_node()
	if target_node:
		var property_path := get_target_property_path()
		if not property_path.is_empty():
			if tween_type == TransitionType.TOGGLE:
				if enable_from:
					target_node.set_indexed(property_path, from_)
				else:
					target_node.set_indexed(property_path, value_)
			else:
				var tween = target_node.create_tween()
				tween.set_trans(tween_type - 1)
				tween.set_ease(tween_ease)
				var t = tween.tween_property(target_node, property_path, value_, length * (Bus.audio_service.metro) * 0.001)
				if enable_from:
					t.from(from_)

func end():
	if tween_type == TransitionType.TOGGLE:
		var target_node = get_target_node()
		if target_node:
			var property_path := get_target_property_path()
			if not property_path.is_empty():
					target_node.set_indexed(property_path, value_)
