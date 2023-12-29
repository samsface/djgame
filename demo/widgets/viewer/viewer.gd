extends Control

var patch_:PDPatch

enum FileMenuIds {
	open = 0
}

func _ready() -> void:
	if not patch_:
		var patch = preload("res://objects/patch.tscn").instantiate()
		patch.open("res://junk/save.pdx")
		add(patch)
	
	reset_camera_()
	
	
	%File.add_item("open", FileMenuIds.open)
	%File.id_pressed.connect(_file_item_pressed)

func _file_item_pressed(id:int) -> void:
	match id:
		FileMenuIds.open:
			open_()

func open_() -> void:
	get_tree().root.get_viewport().gui_embed_subwindows = false
	
	var file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.use_native_dialog = true
	file_dialog.visible = true
	file_dialog.size = Vector2(500, 600)
	file_dialog.initial_position = FileDialog.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	file_dialog.file_selected.connect(open_file_selected_)
	file_dialog.canceled.connect(file_dialog.queue_free)
	add_child(file_dialog)

func open_file_selected_(path:String) -> void:
	var patch = preload("res://objects/patch.tscn").instantiate()
	if not patch.open(path):
		push_error("error opening patch")
		return
		
	add(patch)
	
func add(patch:PDPatch) -> void:
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
