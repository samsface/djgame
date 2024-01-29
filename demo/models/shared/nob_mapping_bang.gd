extends Resource
class_name NobMappingBang

@export var node:NodePath
@export var receiver_symbol:String
@export var send_symbol:String

var p_

func hook(p):
	p_ = p

	var n = p_.get_node_or_null(node)
	if not n:
		return

	n.value_changed.connect(_value_changed)

func _value_changed(r) -> void:
	PureData.send_bang(receiver_symbol)
