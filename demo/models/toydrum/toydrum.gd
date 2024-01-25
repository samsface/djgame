extends Node3D

func _ready() -> void:
	for node in get_children():
		if node is Nob:
			#node.impulse.connect(_impulse)
			node.value_changed.connect(_value_changed.bind(node))

func _value_changed(value, node) -> void:
	pass
