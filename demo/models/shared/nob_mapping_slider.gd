extends Resource 
class_name NobMappingSlider

signal value_changed

@export var node:NodePath
@export var symbol:String
@export var max_value:float
@export var min_value:float

var p_

func hook(p:Node) -> void:
	p_ = p

	var node = p_.get_node_or_null(node)
	if not node:
		pass
			
	node.value_changed.connect(_value_changed)
	node.max_value = max_value

func _value_changed(v:float) -> void:
	PureData.send_float("r-%s-%s" % [p_.name, symbol], v)
	value_changed.emit(v)
