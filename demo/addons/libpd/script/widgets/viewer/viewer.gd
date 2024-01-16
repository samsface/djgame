extends Control

var patch_:PDPatch

enum FileMenuIds {
	open = 0,
	new = 1,
	save_as = 2
}

func _ready() -> void:
	#file_new_()
	#if not patch_:
	#	var patch = preload("res://addons/libpd/script/objects/patch.tscn").instantiate()
	#	patch.open("res://junk/saves.pd")
	#	add(patch)
	
	reset_camera_()
	
	%File.id_pressed.connect(_file_item_pressed)
	%File.add_item("new", FileMenuIds.new)
	%File.add_item("open", FileMenuIds.open)
	%File.add_item("save as", FileMenuIds.save_as)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("file_open"):
		file_open_()

func _file_item_pressed(id:int) -> void:
	match id:
		FileMenuIds.new:
			file_new_()
		FileMenuIds.open:
			file_open_()
		FileMenuIds.save_as:
			file_save_as_()

func file_new_() -> void:
	var patch = preload("res://addons/libpd/script/objects/patch.tscn").instantiate()
	if not patch.open("res://junk/" + str(randi()) + ".pd", FileAccess.WRITE):
		push_error("error opening patch")
		return
		
	add(patch)

func file_open_() -> void:
	get_tree().root.get_viewport().gui_embed_subwindows = false
	
	var file_dialog = FileDialog.new()
	file_dialog.filters = ["*.pd"]
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.use_native_dialog = true
	file_dialog.visible = true
	file_dialog.size = Vector2(500, 600)
	file_dialog.initial_position = FileDialog.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	file_dialog.file_selected.connect(file_open_selected_)
	file_dialog.canceled.connect(file_dialog.queue_free)
	add_child(file_dialog)

func file_open_selected_(path:String) -> void:
	var patch = preload("res://addons/libpd/script/objects/patch.tscn").instantiate()
	if not patch.open(path):
		push_error("error opening patch")
		return
		
	add(patch)

func file_save_as_() -> void:
	if not patch_:
		return
		
	var file_dialog = FileDialog.new()
	file_dialog.filters = ["*.pd"]
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.use_native_dialog = true
	file_dialog.visible = true
	file_dialog.size = Vector2(500, 600)
	file_dialog.initial_position = FileDialog.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	file_dialog.file_selected.connect(file_save_as_selected_)
	file_dialog.canceled.connect(file_dialog.queue_free)
	add_child(file_dialog)
	
	patch_.save()

func file_save_as_selected_(path:String) -> void:
	if not patch_.save(path):
		return

	file_open_selected_(path)

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
