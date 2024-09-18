extends Node3D

var characters_ := []

@export_range(0.0, 3.0) var time_scale:float  = 1.0 :
	set(v):
		time_scale = v
		for character in characters_:
			character.time_scale = v

func _ready() -> void:
	Bus.crowd_service = self
	for child in get_children():
		if child is Character:
			characters_.push_back(child)

	for char:Character in characters_:
		if char != %Mano:
			char.talking = 0.0
			char.jump = randf_range(0.5, 1.0)
			char.cheer_left = randf()
			char.cheer_right = randf()
