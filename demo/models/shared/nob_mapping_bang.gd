extends Resource
class_name NobMappingBang

signal value_changed
signal value_will_change

@export var node:NodePath
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

	var n = p_.get_node_or_null(node)
	if not n:
		return

	n.value_changed.connect(_value_changed)
	n.value_will_change.connect(_value_will_change)

func _value_changed(r) -> void:
	#Bus.audio_service.emit_bang(receiver_symbol_)
	p_.value_changed.emit(p_.get_node(node), 1, 1)

func _value_will_change(time, value) -> void:
	Bus.audio_service.write_at_array_index(array_symbol_, int(time) % 16, value)
