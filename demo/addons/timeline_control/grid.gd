extends Control

@export var color:bool
@export var numbers:bool
@export var y_offset:int

var grid_size = 4.0 :
	set(v):
		grid_size = v
		queue_redraw()
		
func _draw():
	var y = (size.x - position.x)
	var w = (y / grid_size)
	var z = (size.x - y) / grid_size

	var piano_roll_ = get_node("../../../../")
	
	var default_font = ThemeDB.fallback_font
	var default_font_size = ThemeDB.fallback_font_size
	
	#for y in range(1, size.y / grid_size):
	#	draw_line(Vector2(0, y * grid_size), Vector2(size.x, y * grid_size), Color(0.0, 0.0, 0.0, 0.5), 0.5)

	if color:
		for i in %Rows.get_child_count():
			var row = %Rows.get_child(i)
			var rect = row.get_rect()
			rect.position.x = -position.x
			rect.size.x = size.x

			var color = piano_roll_.get_row_header(i).modulate
			color.a = 0.5
			draw_rect(rect, color, true)

	for d in [-z, w]:
	
		for x in range(abs(d)):
			x *= sign(d)
			
			var color := Color(0.0, 0.0, 0.0, 0.05)
		
			if x % 16 == 0:
				color.a = 0.75
			elif x % 4 == 0:
				color.a = 0.25
				
			if numbers:
				if x % 16 == 0:
					draw_string(default_font, Vector2(x * grid_size + 5, 20), str(x / 16), HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)

			draw_line(Vector2(x * grid_size, y_offset), Vector2(x * grid_size, %Rows.size.y), color, 2.0)

func _process(delta: float) -> void:
	RenderingServer.canvas_item_set_custom_rect(get_canvas_item(), true, Rect2(position.x * -1, position.y * -1, 64, 64))

func _zoom_changed(zoom:float) -> void:
	grid_size = zoom
