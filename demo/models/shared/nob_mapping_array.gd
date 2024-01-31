extends Resource
class_name NobMappingArray

signal value_changed

@export var array_name:String :
	set(v):
		if array_name != v:
			array_name = v
			refresh()

@export var node:Array[NodePath]

var p_:Node

func hook(p:Node) -> void:
	p_ = p
	
	refresh()

	for i in node.size():
		var node = p_.get_node_or_null(node[i])
		if not node:
			continue
			
		node.value_changed.connect(_value_changed.bind(i))

func refresh() -> void:
	var data:PackedFloat32Array = PureData.read_array(array_name, 0, PureData.get_array_size(array_name))
	if not data:
		return
	
	for i in node.size():
		if i >= data.size():
			return

		var p = p_.get_node_or_null(node[i])
		if not p:
			continue
		
		p.value = data[i]

func _value_changed(v:float, idx:int) -> void:
	PureData.write_at_array_index(array_name, idx, v * 5.0)
	value_changed.emit(v)
