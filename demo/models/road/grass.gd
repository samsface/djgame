extends Node3D

@export var player_position:Vector3 : 
	set(v):
		player_position = v
		invalidate_()

func invalidate_() -> void:
	pass
