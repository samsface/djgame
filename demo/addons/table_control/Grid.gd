extends ColorRect

var grid_size = 32

func _draw():
	for y in range(1, size.y / grid_size):
		draw_line(Vector2(0, y * grid_size), Vector2(size.x, y * grid_size), Color.LIGHT_BLUE, 0.5)

	for x in range(size.x / grid_size):
		var thickness := 0.5
	
		if x % 16 == 0:
			thickness = 2.0
		elif x % 4 == 0:
			thickness = 1.0
			
			
		draw_line(Vector2(x * grid_size, 32), Vector2(x * grid_size, size.y), Color.LIGHT_BLUE, thickness)
