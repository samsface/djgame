extends Node3D

var characters_ := []

@export_range(0.0, 3.0) var time_scale:float = 1.0 :
	set(v):
		time_scale = v
		for character in characters_:
			character.time_scale = v

@export_range(0.0, 1.0) var jump:float = 1.0 :
	set(v):
		jump = v
		for character in characters_:
			character.jump = v

@export_range(0.0, 1.0) var cheer_left:float = 1.0 :
	set(v):
		cheer_left = v
		for character in characters_:
			character.cheer_left = v

@export_range(0.0, 1.0) var cheer_right:float = 1.0 :
	set(v):
		cheer_right = v
		for character in characters_:
			character.cheer_right = v

@export var emotion : CharacterFace.Emotion :
	set(v):
		emotion = v
		for character in characters_:
			character.emotion = v

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
