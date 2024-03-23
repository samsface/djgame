extends Resource
class_name NobMappingHradio

signal value_changed
signal send

@export var send_symbol:String
@export var receive_symbol:String
@export var node:Array[NodePath]

var p_

func hook(p):
	p_ = p
	Camera.audio_service.connect_to_float(send_symbol, _float)

func _float(v:float) -> void:
	var vi = int(v)
	if node.size() <= vi:
		return
		
	var np = p_.get_node_or_null(node[vi])
	if not np:
		return
	
	np.radio()
