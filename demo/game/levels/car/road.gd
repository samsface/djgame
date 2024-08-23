@tool
extends CSGPolygon3D

@export var width:float :
	set(v):
		width = v
		var poly := PackedVector2Array()
		poly.append(Vector2(-width, 0))
		poly.append(Vector2(-width, 1))
		poly.append(Vector2(width, 1))
		poly.append(Vector2(width, 0))
		polygon = poly
