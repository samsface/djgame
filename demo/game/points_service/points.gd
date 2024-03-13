extends Node3D
class_name Points

var points_ := 0 
var lock_ := false

@onready var text_ = $Text

func hit(points:int) -> void:
	lock_ = false
	
	points_ = points
	
	text_.text = str(points_) + " pts"
	
	if get_parent().combo > 0:
		text_.text += " x %d" % (get_parent().combo + 1)
		
	text_.ok()

func miss(off:float) -> void:
	get_parent().miss()

	if lock_:
		return
	
	lock_ = true

	if get_parent().combo > 0:
		text_.text = "COMBO LOST"
		get_parent().combo = 0
	elif off > 0:
		text_.text = "TOO HIGH"
	else:
		text_.text = "TOO LOW"

	text_.danger()

func no_touch() -> void:
	text_.text = "DON'T TOUCH!"
	get_parent().miss()

func commit():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", scale * 1.5, 0.1)
	tween.tween_property(self, "scale", scale, 0.1)
	get_parent().combo += 1
	get_parent().points += points_ * get_parent().combo
