extends MarginContainer


func _draw() -> void:
	var p =  get_parent().get_parent().get_parent()
	for s in p.selection_:
		draw_rect(Rect2(s.global_position - global_position, s.size), Color.AZURE, false, 1.0)
	
	if p.selection_box_:
		draw_rect(p.selection_box_, Color.AZURE, false, 1.0)
