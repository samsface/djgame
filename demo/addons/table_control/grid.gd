extends Control

var grid_size = 32 :
	set(v):
		grid_size = v
		queue_redraw()

func _draw():
	#for y in range(1, size.y / grid_size):
	#	draw_line(Vector2(0, y * grid_size), Vector2(size.x, y * grid_size), Color(0.0, 0.0, 0.0, 0.5), 0.5)

	for x in range(size.x / grid_size):
		var color := Color(0.0, 0.0, 0.0, 0.05)
	
		if x % 16 == 0:
			color.a = 0.75
		elif x % 4 == 0:
			color.a = 0.25

		draw_line(Vector2(x * grid_size, 20), Vector2(x * grid_size, size.y), color, 2.0)
