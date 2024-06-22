extends Node3D
class_name Points

var points_ := 0 

@onready var text_ = $Text

func hit(points:int, hint:String) -> void:
	points_ = points
	
	text_.text = "+%s hp" % points_
	text_.sub_text = hint

	text_.ok()

func miss(points:int, hint:String, commit := false) -> void:
	points_ = -points

	text_.text = "-%s hp" % abs(points)
	text_.sub_text = hint

	if commit:
		get_parent().hp -= points * 0.001

	text_.danger()

func no_touch() -> void:
	text_.text = "DON'T TOUCH!"
	get_parent().miss()

func commit():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", scale * 1.5, 0.1)
	tween.tween_property(self, "scale", scale, 0.1)
	if points_ > 0:
		get_parent().combo += 1
	else:
		pass
		#Bus.camera_service.camera_.rotation_degrees.z = randf_range(7.0, 12.0)
		#PureData.pitch_scale = 2.0 + randf()
		#get_tree().create_timer(randf_range(0.1, 0.3)).timeout.connect(func(): PureData.pitch_scale = 1.0; Bus.camera_service.camera_.rotation_degrees.z = 0)

	#get_parent().points += points_ * 0.1 #* get_parent().combo
	get_parent().hp += points_ * 0.001
