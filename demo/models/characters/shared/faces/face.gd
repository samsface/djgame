@tool
extends Control
class_name CharacterFace

enum EyeShape {
	OPEN,
	CLOSED_SCRUNCHED,
	X,
	DOT,
	SLANTED_DOWN,
	SLANTED_UP,
	CLOSED,
	VERTICAL_LINE,
	HORIZONTAL_LINES,
	V,
}

enum MouthShape {
	LONG,
	SCREAM,
	DOT,
	SLANTED_LONG,
	SHORT,
	SMILE_SMALL,
	SMILE_LARGE,
	VERTICAL_LINE,
	FROWN_SMALL,
	SMILE_SLIGHT,
}

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
	SURE,
}

const face_map_ := {
	Emotion.NEUTRAL: [EyeShape.OPEN, MouthShape.LONG],
	Emotion.INTENSE: [EyeShape.CLOSED_SCRUNCHED, MouthShape.DOT],
	Emotion.DEAD: [EyeShape.X, MouthShape.DOT],
	Emotion.CONFUSED: [EyeShape.DOT, MouthShape.SLANTED_LONG],
	Emotion.ANGRY: [EyeShape.SLANTED_DOWN, MouthShape.SHORT],
	Emotion.HAPPY: [EyeShape.SLANTED_UP, MouthShape.SMILE_SMALL],
	Emotion.VERY_HAPPY: [EyeShape.CLOSED, MouthShape.SMILE_LARGE],
	Emotion.SURPRISED: [EyeShape.VERTICAL_LINE, MouthShape.VERTICAL_LINE],
	Emotion.NASTY: [EyeShape.HORIZONTAL_LINES, MouthShape.FROWN_SMALL],
	Emotion.SURE: [EyeShape.V, MouthShape.SMILE_SLIGHT]
}

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
		mouth_emotion = v
	
		var tween = create_tween()

		tween.tween_property(self, "scale:y", 0.1, 0.05)
		tween.tween_property(self, "scale:y", 1.0, 0.1)
	
var left_eye_emotion:Emotion :
	set(v):
		left_eye_emotion = v
		var idx:int = face_map_[v][0]
		if is_node_ready():
			$Eyes/LeftEye.texture.region.position.x = ((idx % 4) * 2 + 1) * 128
			$Eyes/LeftEye.texture.region.position.y = floor((idx * 2) / 8) * 128

var right_eye_emotion:Emotion :
	set(v):
		right_eye_emotion = v
		var idx:int = face_map_[v][0]
		if is_node_ready():
			$Eyes/RightEye.texture.region.position.x = ((idx % 4) * 2) * 128
			$Eyes/RightEye.texture.region.position.y = floor((idx * 2) / 8) * 128

var mouth_emotion:Emotion :
	set(v):
		mouth_emotion = v
		var idx:int = face_map_[v][1]
		$Mouth.texture.region.position.x = ((idx % 8)) * 128
		$Mouth.texture.region.position.y = floor(idx / 8) * 128

func _ready() -> void:
	blink_()

func blink_() -> void:
	var blink_tween := create_tween()
	blink_tween.tween_property($Eyes, "scale:y", 0.0, 0.1)
	blink_tween.tween_property($Eyes, "scale:y", 1.0, 0.)
	get_tree().create_timer(randf() * 13.0).timeout.connect(blink_)
