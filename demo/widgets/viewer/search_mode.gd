extends Mode
class_name SearchMode

static func test(input, selection) -> bool:
	return input.is_action_pressed("search")

func _ready() -> void:
		get_viewport().set_input_as_handled()
		var x = preload("res://widgets/search/search.tscn").instantiate()
		x.position = get_global_mouse_position()
		x.end.connect(search_end_)
		add_child(x)

func search_end_(search_text:String) -> void:
	if search_text:
		get_parent().add_node_(search_text)
	
	queue_free()
