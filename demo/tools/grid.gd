extends ColorRect

func _draw():
	for y in range(1, size.y / 32):
		draw_line(Vector2(0, y * 32), Vector2(size.x, y * 32), Color.LIGHT_BLUE, 1.0)
		
	for x in range(size.x / 32):
		draw_line(Vector2(x * 32, 0), Vector2(x * 32, size.y), Color.LIGHT_BLUE, 1.0)
