extends Resource
class_name NobMappingExpr

signal value_changed

@export var node:NodePath
@export var expr:String

var p_

func hook(p) -> void:
	if not p:
		return
	
	p_ = p
	
	var n = p_.get_node_or_null(node)
	if not n:
		return
	
	n.value_changed.connect(_value_changed)

func _value_changed(v) -> void:
	var e = Expression.new()
	var res = e.parse(expr)
	if res != OK:
		return
		
	e.execute([], self)
	
func set_array_name(idx:int, value:String) -> void:
	if p_.map.arrays.size() <= idx:
		return

	p_.map.arrays[idx].array_name = value
