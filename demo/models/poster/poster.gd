@tool
extends Node3D

@export var size:Vector2 = Vector2(1, 1):
	set(v):
		size = v
		await ready
		invalidate_()

func invalidate_() -> void:
	$MeshInstance3D.mesh.size = size
	$Area3D/CollisionShape3D.shape.size.x = size.x
	$Area3D/CollisionShape3D.shape.size.y = size.y

func _mouse_entered() -> void:
	$MeshInstance3D.set_instance_shader_parameter("border_color", Color(1, 0, 0, 1))

func _mouse_exited() -> void:
	$MeshInstance3D.set_instance_shader_parameter("border_color", Color(1, 0, 0, 0))
