extends Node3D

var delta_sum_ := 0.0

func _ready() -> void:
	pass

func cheer() -> void:
	pass

func _physics_process(delta: float) -> void:
	delta_sum_ += delta
	visible = sin(delta_sum_ * 100.0) > -0.5
