@tool
extends Character

func _ready() -> void:
	talking = randf()

	for node in %Skeleton3D.get_children():
		node.set_instance_shader_parameter("albedo", HyperRandom.fruity_color())
