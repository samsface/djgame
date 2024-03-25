extends ProgressBar

signal zero

var inc_tween_:Tween
var dec_tween_:Tween
var value_ := 0.0

var good_color_ := Color("00ba00")

func _ready() -> void:
	value_ = value
	pivot_offset = size * 0.5
	get_parent().pivot_offset = get_parent().size * 0.5

func set_points(v:float) -> void:
	if v < value_:
		dec_(v)
	else:
		inc_(v)
		
	if value_ == 0.0:
		zero.emit()

func decay(v:float) -> void:
	if inc_tween_ and inc_tween_.is_running():
		return
		
	if dec_tween_ and dec_tween_.is_running():
		return

	value_ -= v
	value_ = clampf(value_, 0.0, 1.0)
	value = value_
	
	#if value_ <= 0.0:
	#	zero.emit()

func dec_(v):
	value_ = clampf(v, 0.0, 1.0)
	
	if inc_tween_:
		inc_tween_.kill()

	if dec_tween_ and dec_tween_.is_running():
		if dec_tween_.get_total_elapsed_time() < 0.1:
			return
		dec_tween_.kill()

	dec_tween_ = create_tween()
	dec_tween_.set_parallel()
	dec_tween_.tween_property(self, "value", value_, 0.1)
	dec_tween_.tween_property(self, "modulate", Color.RED, 0.1)
	dec_tween_.tween_property(self, "modulate", good_color_, 0.1).set_delay(0.1)

func inc_(v):
	value_ = clampf(v, 0.0, 1.0)
	
	if dec_tween_:
		dec_tween_.kill()
	
	if inc_tween_:
		inc_tween_.kill()

	inc_tween_ = create_tween()
	inc_tween_.set_parallel()
	inc_tween_.tween_property(self, "value", value_, 0.1)
	inc_tween_.tween_property(self, "modulate", Color.WHITE, 0.1)
	inc_tween_.tween_property(self, "modulate", good_color_, 0.1).set_delay(0.1)
