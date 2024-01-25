extends Resource
class_name NobMappingHradio

signal send

@export var send_symbol:String
@export var receive_symbol:String
@export var node:Array[NodePath]

var p_

func hook(p):
	p_ = p
	PureData.bind(send_symbol)
	PureData.float.connect(func(s, v): if s == send_symbol: _float(s, v))

func _float(r:String, v:float) -> void:
	var vi = int(v)
	if node.size() <= vi:
		return
		
	var np = p_.get_node_or_null(node[vi])
	if not np:
		return
	
	np.radio()
