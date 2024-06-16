extends RythmicAnimationPlayerControlItem
class_name PianoRollItemSlide

@export var from_value:float : 
	set(v):
		from_value = v
		invalidate_value_()

@export var value:float : 
	set(v):
		value = v
		invalidate_value_()

@export var gluide:float = 0.5 :
	set(v):
		gluide = v
		invalidate_value_()

func _ready():
	self_modulate = Color.DARK_SLATE_GRAY
	$Polygon2D.self_modulate = Color.LIGHT_GREEN
	invalidate_value_()
	item_rect_changed.connect(invalidate_value_)

func invalidate_value_() -> void:
	var polygon := PackedVector2Array()
	polygon.resize(4)
	
	var from = 1.0 - from_value
	var to = 1.0 - value
		
	var border_width := 1

	var style_box:StyleBoxFlat = get_theme_stylebox("normal", "button")
	if style_box:
		border_width = style_box.border_width_bottom
	
	border_width = 2;
	
	polygon[0] = Vector2(0, from * size.y)
	polygon[1] = Vector2(size.x, to * size.y)
	polygon[2] = Vector2(size.x, size.y )
	polygon[3] = Vector2(0, size.y)
	
	$Polygon2D.scale = Vector2(1.0 - ((border_width * border_width)  / size.x), 1.0 - ((border_width * border_width) / size.y))
	$Polygon2D.position = Vector2.ONE + Vector2.ONE * border_width * 0.5
	
	$Polygon2D.polygon = polygon

func begin() -> void:
	var length_in_seconds = length * (Bus.audio_service.metro) * 0.001
	get_target_node().slide(length_in_seconds, from_value, value, gluide)
