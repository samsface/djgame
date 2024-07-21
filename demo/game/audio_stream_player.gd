extends AudioStreamPlayer

func _process(delta: float) -> void:
	if not playing and get_parent().is_visible_in_tree():
		playing = true
	
	if playing and not get_parent().is_visible_in_tree():
		playing = false
