extends Control

var grid_size = 32 :
	set(v):
		grid_size = v
		queue_redraw()

func _draw():
	var default_font = ThemeDB.fallback_font
	var default_font_size = ThemeDB.fallback_font_size
	
	#for y in range(1, size.y / grid_size):
	#	draw_line(Vector2(0, y * grid_size), Vector2(size.x, y * grid_size), Color(0.0, 0.0, 0.0, 0.5), 0.5)

	var w = 1000#size.x / grid_size


	for d in [-1, 1]:
	
		for x in range(w):
			x *= d
			
			var color := Color(0.0, 0.0, 0.0, 0.05)
		
			if x % 16 == 0:
				color.a = 0.75
			elif x % 4 == 0:
				color.a = 0.25
				
			if x % 16 == 0:
				draw_string(default_font, Vector2(x * grid_size, 20), str(x / 16), HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)

			draw_line(Vector2(x * grid_size, 96), Vector2(x * grid_size, size.y), color, 2.0)
