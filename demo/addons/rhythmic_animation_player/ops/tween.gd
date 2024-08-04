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

var value_
var from_

var value_before_begin_

func _ready():
	invalidate_value_()
	
	var dict := {}
	dict[5] = 5
	dict[15] = 15
	dict[1] = 1
	dict[2] = 2

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
		else:
			return 0 

func _get_property_list():
	var value_type = deduce_type_()
	if value_type == TYPE_NIL:
		return []

	var properties := []
	
	if enable_from:
		properties.append({
			"name": "from",
			"type": value_type,
			"usage": 4102
		})
	
		
	properties.append({
		"name": "value",
		"type": value_type,
		"usage": 4102
	})

	return properties

func invalidate_value_() -> void:
	self_modulate = Color.DARK_SLATE_GRAY
	

func infer_type(value):
	if typeof(value_before_begin_) == TYPE_BOOL:
		return bool(value)
	else:
		return value

func get_target_node_property_value_():
	var target_node = get_target_node()
	if target_node:
		var property_path := get_target_property_path()
		if not property_path.is_empty():
			return target_node.get_indexed(property_path)

	return null

func deduce_type_():
	var target_node = get_target_node()
	if target_node:
		var property_path := get_target_property_path()
		if not property_path.is_empty():
			var value = target_node.get_indexed(property_path)
			return typeof(value)
	
	return TYPE_NIL
	$Label.text = "%s" % [to_value]

var tween_:Tween

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



	var target_node = get_target_node()
	if target_node:
		var property_path := get_target_property_path()
		if not property_path.is_empty():
			if tween_type == TransitionType.TOGGLE:
				target_node.set_indexed(property_path, value_)
			else:
				var elapsed_time = ((t - time) / float(length))
	

				if elapsed_time >= 1.0:
					target_node.set_indexed(property_path, value_)
				elif elapsed_time <= 0.0:
					target_node.set_indexed(property_path, from_)
				else:
					var new_value = tween_.interpolate_value(from, subtract_variant(value_, from), elapsed_time, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
					prints(target_node, elapsed_time)
					target_node.set_indexed(property_path, new_value)

func begin():
	flash()
	
	var target_node = get_target_node()
	if target_node:
		var property_path := get_target_property_path()
		if not property_path.is_empty():
			value_before_begin_ = target_node.get_indexed(property_path)
			if tween_type == TransitionType.TOGGLE:
				target_node.set_indexed(property_path, value_)
			else:
				var tween = target_node.create_tween()
				tween.tween_property(target_node, property_path, value_, length * (Bus.audio_service.metro) * 0.001)#.from(from_value)

func end():
	if tween_type == TransitionType.TOGGLE:
		var target_node = get_target_node()
		if target_node:
			var property_path := get_target_property_path()
			if not property_path.is_empty():
					target_node.set_indexed(property_path, value_)
