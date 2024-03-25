extends Node3D

var delta_sum_ := 0.0

func _ready() -> void:
	pass

func clap() -> void:
	$Clap.play()

func _physics_process(delta: float) -> void:
	delta_sum_ += delta
	visible = sin(delta_sum_ * 100.0) > -0.5

func look(view_position_idx:int = 0) -> void:
	Camera.look_at_node(self)

func get_view_position(from_position := Vector3.ZERO) -> Vector3:
	return $Marker3D.global_position
