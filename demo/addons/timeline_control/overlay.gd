extends MarginContainer

func _draw() -> void:
	var p =  get_parent().get_parent().get_parent().get_parent().get_parent()
	for s in p.selection_:
		if is_instance_valid(s):
			draw_rect(Rect2(s.global_position - global_position, s.size), Color.AZURE, false, 1.0)
	
	if p.selection_box_:
		draw_rect(p.selection_box_, Color.AZURE, false, 1.0)

func _process(delta: float) -> void:
	RenderingServer.canvas_item_set_custom_rect(get_canvas_item(), true, Rect2(get_parent().position.x * -1, get_parent().position.y * -1, 64, 64))
