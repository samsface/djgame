extends GridItem

enum Type {
	bang,
	slide
}

@export var type:Type : 
	set(value):
		type = value
		invalidate_type_()
		invalidate_value_()
		
@export var time:int : 
	set(value):
		position.x = value * 32
	get:
		return int(position.x / 32)

@export var length:int = 1 : 
	set(value):
		size.x = value * 32
	get:
		return int(size.x / 32)

@export var from_value:float : 
	set(v):
		from_value = v
		invalidate_value_()

@export var value:float : 
	set(v):
		value = v
		invalidate_value_()

func _ready():
	invalidate_value_()
	item_rect_changed.connect(invalidate_value_)

func invalidate_type_() -> void:
	match type:
		Type.bang:
			$TextureRect.texture = preload("res://tools/bang.png")
		Type.slide:
			$TextureRect.texture = preload("res://tools/slide.png")

func invalidate_value_() -> void:
	var polygon := PackedVector2Array()
	polygon.resize(4)
	
	var from = 1.0 - from_value
	var to = 1.0 - value
	
	if type == Type.bang:
		from = to
	
	polygon[0] = Vector2(0, from * size.y)
	polygon[1] = Vector2(size.x, to * size.y)
	polygon[2] = Vector2(size.x, size.y)
	polygon[3] = Vector2(0, size.y)
	$Polygon2D.polygon = polygon
