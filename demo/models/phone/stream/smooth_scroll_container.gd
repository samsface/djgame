extends ScrollContainer
class_name SmoothScrollContainer

var tween_:Tween

func _ready() -> void:
	get_child(0).child_entered_tree.connect(_child_entered_tree)

func _child_entered_tree(node) -> void:
	await  get_tree().process_frame
	if tween_:
		tween_.kill()
	
	tween_ = create_tween()
	tween_.set_ease(Tween.EASE_IN)
	tween_.tween_property(self, "scroll_vertical", get_child(0).size.y - size.y, 0.2)
	
