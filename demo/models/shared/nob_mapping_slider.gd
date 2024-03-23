extends Resource 
class_name NobMappingSlider

@export var node:NodePath
@export var symbol:String
@export var max_value:float
@export var min_value:float

var p_
var nob_:Nob

func hook(p:Node) -> void:
	p_ = p

	nob_ = p_.get_node_or_null(node)
	if not nob_:
		return
			
	nob_.value_changed.connect(_value_changed)

func _value_changed(new_value:float, old_value:float) -> void:
	#print("v", new_value * (max_value - min_value) + min_value)
	
	Camera.audio_service.emit_float("%s-%s" % [p_.name, symbol], new_value * (max_value - min_value) + min_value)
	p_.value_changed.emit(nob_, new_value, old_value)
