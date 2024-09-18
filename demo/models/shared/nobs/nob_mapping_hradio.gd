extends Resource
class_name NobMappingHradio

signal value_changed
signal send

@export var node_paths:Array[NodePath]
@export var symbol:String : 
	set(v):
		symbol = v
		receiver_symbol_ = "r-" + symbol
		send_symbol_ = "s-" + symbol
		array_symbol_ = "a-" + symbol

var p_
var receiver_symbol_:String
var send_symbol_:String
var array_symbol_:String 

func hook(p):
	p_ = p
	Bus.audio_service.connect_to_float(send_symbol_, _float)
	
	for i in node_paths.size():
		var np = p_.get_node_or_null(node_paths[i])
		if not np:
			continue
		
		np.value_changed.connect(_value_changed.bind(i))

func _float(v:float) -> void:
	var vi = int(v)
	if node_paths.size() <= vi:
		return
		
	var np = p_.get_node_or_null(node_paths[vi])
	if not np:
		return
	
	np.radio()

func _value_changed(x, value:int) -> void:
	Bus.audio_service.emit_float(symbol, value)
