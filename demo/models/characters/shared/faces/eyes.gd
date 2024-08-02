@tool
extends Control

enum EyeEmoition {
	NEUTRAL,
	INTENSE,
	DEAD,
	WITHDRAWN,
	ANGRY,
	HAPPY,
	VERY_HAPPY,
	TALL,
	TIRED,
	SURE
}

const eye_motions_values_:Array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

@export var both_eyes_emotion:EyeEmoition :
	set(v):
		both_eyes_emotion = v
		left_eye_emotion = v
		right_eye_emotion = v

@export var left_eye_emotion:EyeEmoition :
	set(v):
		left_eye_emotion = v
		var idx:int = eye_motions_values_[v]
		if is_node_ready():
			$LeftEye.texture.region.position.x = ((idx % 4) * 2 + 1) * 128
			$LeftEye.texture.region.position.y = floor((idx * 2) / 8) * 128
			
			prints(((idx % 8) * 2 + 1) * 128, floor((idx * 2) / 8) * 128)

@export var right_eye_emotion:EyeEmoition :
	set(v):
		right_eye_emotion = v
		var idx:int = eye_motions_values_[v]
		if is_node_ready():
			$RightEye.texture.region.position.x = ((idx % 4) * 2) * 128
			$RightEye.texture.region.position.y = floor((idx * 2) / 8) * 128
