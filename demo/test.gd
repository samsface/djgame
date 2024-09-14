@tool
extends Node3D

func _process(delta: float) -> void:
	$Arrow.global_position = $MeshInstance3D.global_position + Vector3.UP * 3.0 + Vector3.ONE * 0.001
	$Arrow.look_at($MeshInstance3D.global_position)
