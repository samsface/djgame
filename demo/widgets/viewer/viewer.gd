extends SubViewportContainer

var patch_:PDPatch

func _ready() -> void:
	if not patch_:
		var patch = preload("res://objects/patch.tscn").instantiate()
		patch.open("res://addons/libpd/maker_test.pd")
		add(patch)
	
	reset_camera_()

func add(patch:PDPatch) -> void:
	if not patch:
		return
		
	patch_ = patch

	%Root.add_child(patch)

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
