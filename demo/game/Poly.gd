@tool
extends CSGPolygon3D

@export var sides := 8 :
	set(value):
		sides = clamp(value, 3, 32)
		invalidate_()

@export_range(0.0, 0.0189) var diameter := 0.0189 :
	set(value):
		diameter = value
		invalidate_()

func invalidate_() -> void:
	var angle_increment: float = 2.0 * PI / float(sides)
	
	var new_polygon := PackedVector2Array()
	new_polygon.resize(sides)
	
	for i in range(sides):
		var x: float = cos(angle_increment * i)
		var y: float = sin(angle_increment * i)
		new_polygon[i] = Vector2(x, y) * diameter

	polygon = new_polygon
