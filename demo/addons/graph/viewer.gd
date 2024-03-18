extends Control

var patch_:GraphControl

enum FileMenuIds {
	open = 0,
	new = 1,
	save_as = 2
}

func _ready() -> void:
	reset_camera_()
	add(GraphControl.new())

func add(patch) -> void:
	if not patch:
		return

	if patch_:
		patch_.queue_free()
		%Root.remove_child(patch_)
		
	patch_ = patch

	%Root.add_child(patch_)

func _exit_tree() -> void:
	# remove child to escape queue_free
	%Root.remove_child(patch_)

func reset_camera_() -> void:
	if not patch_:
		return

	var avg := Vector2.ZERO
	for node in patch_.get_children():
		avg += node.position

	avg = avg / patch_.get_child_count()
	
	%Camera2D.position = avg
