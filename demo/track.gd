extends Node3D

class Frame:
	var beat:int
	var value:float
	var smooth:bool

var tracks := {
	^"acid/2:value": [[0, 127]]
}

func _ready() -> void:
	for track in tracks:
		var node = get_parent().get_node_or_null(track)
		
		var demon = preload("res://demos/demo.tscn").instantiate()
	
		demon.position = node.global_position + node.global_rotation

