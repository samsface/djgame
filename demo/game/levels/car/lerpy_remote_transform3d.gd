extends PathFollow3D

@export var node:Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not node:
		return
		
	node.position = position
	node.rotation = lerp(node.rotation, rotation, delta * 0.3)
