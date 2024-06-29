extends Resource 
class_name NobMappingSlider

@export var node:NodePath
@export var symbol:String
@export var max_value:float
@export var min_value:float
@export var logarithmic:bool

var p_
var nob_:Nob

func hook(p:Node) -> void:
	p_ = p

	nob_ = p_.get_node_or_null(node)
	if not nob_:
		return
			
	nob_.value_changed.connect(_value_changed)

func _value_changed(new_value:float, old_value:float) -> void:

	if logarithmic:
		new_value = (pow(10.0, new_value) - 1.0) / 9.0
	
	print(new_value)
	
	var v = new_value * (max_value - min_value) + min_value

	Bus.audio_service.emit_float("%s-%s" % [p_.name, symbol], v)
	p_.value_changed.emit(nob_, new_value, old_value)
