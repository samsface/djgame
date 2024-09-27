extends Node3D
class_name Points

var points_ := 0 
var bar

@onready var text_ = $Text

var points := 0 : 
	set(v):
		var diff = v - points_
	
		if diff > 0:
			points_ = v
			hit()
		elif diff < 0:
			points_ = v
			miss()
	get:
		return points_

func hit() -> void:
	text_.color = bar.color
	text_.text = "%s%s %s" % ["-" if points < 0 else "+", abs(points_), bar.unit]

func miss() -> void:
	text_.color = Color.RED
	text_.text = "%s%s %s" % ["-" if points < 0 else "+", abs(points_), bar.unit]

func no_touch() -> void:
	text_.text = "NO!"

func commit(free_on_finish := false):
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", scale * 1.5, 0.1)
	tween.tween_property(self, "scale", scale, 0.1)
	if points_ > 0:
		bar.combo += 1
	else:
		pass
		#Bus.camera_service.camera_.rotation_degrees.z = randf_range(7.0, 12.0)
		#PureData.pitch_scale = 2.0 + randf()
		#get_tree().create_timer(randf_range(0.1, 0.3)).timeout.connect(func(): PureData.pitch_scale = 1.0; Bus.camera_service.camera_.rotation_degrees.z = 0)

	#get_parent().points += points_ * 0.1 #* get_parent().combo
	bar.value += points * 0.001
	
	if free_on_finish:
		tween.finished.connect(queue_free)
