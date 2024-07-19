extends SpotLight3D

@export var strobe:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if strobe:
		visible = not visible
	else:
		rotation_degrees.y += delta * 100.0
