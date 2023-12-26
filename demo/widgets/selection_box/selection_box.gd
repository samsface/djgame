extends Area2D

@export var size:Vector2 : 
	set(value):
		size = value
		invalidate_()

func invalidate_():
	$Polygon2D.polygon[1] = Vector2(size.x, 0)
	$Polygon2D.polygon[2] = Vector2(size.x, size.y)
	$Polygon2D.polygon[3] = Vector2(0, size.y)
	$CollisionPolygon2D.polygon[1] = Vector2(size.x, 0)
	$CollisionPolygon2D.polygon[2] = Vector2(size.x, size.y)
	$CollisionPolygon2D.polygon[3] = Vector2(0, size.y)
	#$CollisionPolygon2D.disabled = true
	#$CollisionPolygon2D.disabled = false
	
func _ready() -> void:
	if not Input.is_action_pressed("shift"):
		SelectionBus.clear_selection()

func _physics_process(delta: float):
	if Input.is_action_just_released("click"):
		queue_free()
		SelectionBus.add_all(get_overlapping_areas())
	else:
		size.x = get_global_mouse_position().x - global_position.x
		size.y = get_global_mouse_position().y - global_position.y

func _area_entered(area: Area2D) -> void:
	print(area)
