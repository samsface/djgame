extends CanvasLayer
class_name HudCanvasLayer

func _ready() -> void:
	await get_tree().process_frame

	var root = get_tree().root

	get_parent().tree_exiting.connect(queue_free)
	get_parent().remove_child(self)

	root.add_child(self)
