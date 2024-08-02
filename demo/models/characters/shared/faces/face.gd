@tool
extends Control
class_name CharacterFace

enum Emotion {
	NEUTRAL,
	INTENSE,
	DEAD,
	CONFUSED,
	ANGRY,
	HAPPY,
	VERY_HAPPY,
	SURPRISED,
	NASTY,
	SURE
}

const eye_motions_values_:Array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

@export_range(0, 1) var eye_height:float : 
	set(v):
		eye_height = v
		$Eyes.position.y = v * size.y
		
@export_range(0, 1) var pupil_distance:float :
	set(v):
		pupil_distance = v
		$Eyes/LeftEye.position.x = pupil_distance * size.x  -64
		$Eyes/RightEye.position.x = -pupil_distance * size.x -64
	
@export_range(0, 1) var eye_scale:float = 1.0 :
	set(v):
		eye_scale = v
		$Eyes/LeftEye.scale = Vector2.ONE * v * 2.0
		$Eyes/RightEye.scale = Vector2.ONE * v * 2.0

@export_range(0, 1) var mouth_height:float = 1.0 :
	set(v):
		mouth_height = v
		$Mouth.position.y =  v * size.y - 64

@export_range(0, 1) var mouth_scale:float :
	set(v):
		mouth_scale = v
		$Mouth.scale.x =  v

@export var emotion:Emotion :
	set(v):
		emotion = v
		left_eye_emotion = v
		right_eye_emotion = v
		var idx:int = eye_motions_values_[v]
		$Mouth.texture.region.position.x = ((idx % 8)) * 128
		$Mouth.texture.region.position.y = floor(idx / 8) * 128
	
var left_eye_emotion:Emotion :
	set(v):
		left_eye_emotion = v
		var idx:int = eye_motions_values_[v]
		if is_node_ready():
			$Eyes/LeftEye.texture.region.position.x = ((idx % 4) * 2 + 1) * 128
			$Eyes/LeftEye.texture.region.position.y = floor((idx * 2) / 8) * 128

var right_eye_emotion:Emotion :
	set(v):
		right_eye_emotion = v
		var idx:int = eye_motions_values_[v]
		if is_node_ready():
			$Eyes/RightEye.texture.region.position.x = ((idx % 4) * 2) * 128
			$Eyes/RightEye.texture.region.position.y = floor((idx * 2) / 8) * 128
