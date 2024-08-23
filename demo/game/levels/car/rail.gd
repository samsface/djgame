@tool
extends CSGPolygon3D

@export var invalidate:bool :
	set(v):
		invalidate_()
		invalidate = false

@export var polygon_scale:Vector2 :
	set(v):
		polygon_scale = v
		invalidate_()

@export var polygon_offset:Vector2 :
	set(v):
		polygon_offset = v
		invalidate_()

func invalidate_() -> void:
	if not is_node_ready():
		await ready
	var poly:PackedVector2Array = $Polygon2D.polygon
	for i in poly.size():
		poly[i] *= polygon_scale
		poly[i] += polygon_offset

		
	
	
	polygon = poly
