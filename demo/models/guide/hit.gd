extends Label3D
class_name FlashText

var tween_:Tween
var accuracy := 0.0

func good() -> Tween:
	visible = true
	modulate = Color.GREEN
	text = ["SICK!", "GUD!", "NICE!", "YEAH!"].pick_random()
	tween_ = create_tween()
	tween_.set_parallel()
	#text_tween.tween_property($Hit, ^"position:y", $Hit.position.y + 0.05, 1.5).set_delay(0.2)
	tween_.tween_property(self, ^"transparency", 1.0, 0.1).set_delay(0.25)

	return tween_

func bad() -> Tween:
	visible = true
	modulate = Color.RED

	if accuracy <= -1:
		text = "OPS!"
	elif accuracy > 0.0:
		text = "TOO HIGH!"
	else:
		text = "TOO LOW!"

	tween_ = create_tween()

	tween_.set_parallel(false)
	for i in 4:
		tween_.tween_property(self, ^"visible", false, 0.0).set_delay(0.1)
		tween_.tween_property(self, ^"visible", true, 0.0).set_delay(0.1)

	tween_.tween_property(self, ^"visible", false, 0.0).set_delay(0.0)

	return tween_
