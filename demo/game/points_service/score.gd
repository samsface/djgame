extends Label

var tween_:Tween
var value_ := 0

func _ready() -> void:
	pivot_offset = size * 0.5
	get_parent().pivot_offset = get_parent().size * 0.5

func set_points(value:int) -> void:
	if tween_:
		tween_.kill()

	tween_ = create_tween()
	tween_.set_parallel()
	tween_.tween_method(func(v): value_ = v; text = str(value_) + " pts", value_, value, 2.0)

	tween_.tween_property(get_parent(), "scale", Vector2.ONE * 1.2, 0.05)
	tween_.tween_property(get_parent(), "scale", Vector2.ONE, 0.1).set_delay(0.05)
