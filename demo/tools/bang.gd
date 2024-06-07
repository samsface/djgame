extends PianoRollItem
class_name PianoRollItemBang

@export var value:float = 1.0 : 
	set(v):
		value = v
		invalidate_value_()

@export var auto:bool : 
	set(v):
		auto = v
		invalidate_value_()

@export var dilema_group:int : 
	set(v):
		dilema_group = v

@export var silent:bool : 
	set(v):
		silent = v

func _ready():
	invalidate_value_()
	item_rect_changed.connect(invalidate_value_)

func get_lookahead() -> int:
	return 10

func invalidate_value_() -> void:
	self_modulate = Color.DARK_SLATE_GRAY
	
	$Label.text = " "
	
	var label_text := []

	if dilema_group:
		label_text.push_back("?")
	
	if auto:
		label_text.push_back("Auto")
		
	label_text.push_back("Bang")

	$Label.text += ":".join(label_text)

	var polygon := PackedVector2Array()
	polygon.resize(4)
	
	var from = 1.0 - value
	var to = 1.0 - value

	from = to
		
	var border_width := 1

	var style_box:StyleBoxFlat = get_theme_stylebox("normal", "button")
	if style_box:
		border_width = style_box.border_width_bottom

	polygon[0] = Vector2(0, from * size.y)
	polygon[1] = Vector2(size.x, to * size.y)
	polygon[2] = Vector2(size.x, size.y )
	polygon[3] = Vector2(0, size.y)
	
	$Polygon2D.scale = Vector2(1.0 - ((border_width * border_width)  / size.x), 1.0 - ((border_width * border_width) / size.y))
	$Polygon2D.position = Vector2.ONE + Vector2.ONE * border_width * 0.5
	
	$Polygon2D.polygon = polygon

func op(db, node, length_) -> void:
	if node.has_method("bang"):
		var length = (get_lookahead() / 16.0) * (PureData.metro) * (1.0/60.0)
		node.bang(get_lookahead(), value, auto, dilema_group, silent)
