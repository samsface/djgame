extends Control

signal bang

var undo_ = UndoRedo.new()

enum Tool {
	none,
	resizing,
	moving,
	resizing_time_begin,
	resizing_time_end
}

var selected_key_
var selected_key_time_
var select_key_start_position_
var tool_:Tool = Tool.moving
var playing_ := true
var time_ := 0.0
var playing_idx_ := {}

var track_times_ := {}

var time_range_ = Vector2i(0, 16)

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 16 * 4:
		var h := preload("res://tools/heading.tscn").instantiate()
		if i % 4 == 0:
			h.text = str(floor(i / 16)) + "." + str(i % 16)
		else:
			h.text = ""
		%Headings.add_child(h)

	reload()
	
	await  get_tree().process_frame
	set_time_range_(time_range_)

func _key_button_down(key) -> void:
	selected_key_time_ = Time.get_unix_time_from_system()
	
	selected_key_ = key
	select_key_start_position_ = selected_key_.position

	print(selected_key_.size.x - selected_key_.get_local_mouse_position().x )

	if selected_key_.size.x - selected_key_.get_local_mouse_position().x < 14:
		tool_ = Tool.resizing
		undo_.create_action("resize_key")
		undo_.add_undo_property(selected_key_, "size", selected_key_.size)
	else:
		tool_ = Tool.moving
		undo_.create_action("move_key")
		undo_.add_undo_property(selected_key_, "position", selected_key_.position)

func _key_button_up(key) -> void:
	undo_.commit_action(false)
	
	#if Time.get_unix_time_from_system() - selected_key_time_ < 0.3:
	#		undo_.commit_action(false)
			#undo_.create_action("set key type")
			#undo_.add_do_property(key, "type", (key.type + 1) % 2)
			#undo_.add_undo_property(key, "type", key.type)
	#		return
	if tool_ == Tool.moving:
		undo_.add_do_property(selected_key_, "position:x", selected_key_.position)
	elif tool_ == Tool.resizing:
		undo_.add_do_property(selected_key_, "size:x", selected_key_.size)

	undo_.add_do_method(selected_key_.get_parent().invalidate_queue)
	undo_.add_undo_method(selected_key_.get_parent().invalidate_queue)

	undo_.commit_action()
	
	selected_key_ = null

func _key_right_click(key) -> void:
	var key_parent = key.get_parent()
	
	undo_.create_action("erase_key")
	undo_.add_undo_reference(key)
	undo_.add_do_method(key_parent.remove_child.bind(key))
	undo_.add_undo_method(key_parent.add_child.bind(key))
	undo_.add_do_method(key_parent.invalidate_queue)
	undo_.add_undo_method(key_parent.invalidate_queue)
	undo_.commit_action()

func _key_mouse_entered(key) -> void:
	key.show_resize_handle()
	%Inspector.node = key

func _key_mouse_exited(key) -> void:
	key.hide_resize_handle()

func _input(event) -> void:
	if event is InputEventMouseButton:
		if not event.pressed:
			tool_ = Tool.none
			return
			
	if event.is_action_pressed("redo"):
		undo_.redo()
	elif event.is_action_pressed("undo"):
		undo_.undo()
	
	var time = clamp(floor(%Tracks.get_local_mouse_position().x / 32), 0 , 2048)
	
	if selected_key_:
		if event is InputEventMouseMotion:
			if tool_ == Tool.resizing:
				time += 1
				if selected_key_.time + selected_key_.length != time:
					selected_key_.length = (time - selected_key_.time)
			else:
				if selected_key_.time != time:
					selected_key_.time = time
	else:
		if tool_ == Tool.resizing_time_begin:
			set_time_range_(Vector2i(time, time_range_.y))
		elif tool_ == Tool.resizing_time_end:
			set_time_range_(Vector2i(time_range_.x, time))
		
func _key_time_changed(key:Control):
	key.position.x = key.time * 32

func _key_length_changed(key:Control):
	key.size.x = key.length * 32

func _inspector_split_dragged(offset):
	pass
	#$HSplitContainer2.split_offset = offset

func _track_gui_input(event:InputEvent, track:Control) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			add_key_(track)

func add_key_(track) -> void:
	undo_.create_action("add key")

	var time = clamp(floor(track.get_local_mouse_position().x / 32), 0 , 2048)
	var key = preload("res://tools/bang.tscn").instantiate()
	connect_key_signals_(key)
	key.time = time
	undo_.add_do_reference(key)
	undo_.add_do_method(track.add_child.bind(key))
	undo_.add_undo_method(track.remove_child.bind(key))
	undo_.add_do_method(track.invalidate_queue)
	undo_.add_undo_method(track.invalidate_queue)
	undo_.commit_action()

func connect_key_signals_(key):
	key.time_changed.connect(_key_time_changed.bind(key))
	key.length_changed.connect(_key_length_changed.bind(key))
	key.button_down.connect(_key_button_down.bind(key))
	key.button_up.connect(_key_button_up.bind(key))
	key.right_click.connect(_key_right_click.bind(key))
	key.mouse_entered.connect(_key_mouse_entered.bind(key))
	key.mouse_exited.connect(_key_mouse_exited.bind(key))

func add_track(node_path:NodePath = "") -> Control:
	for track in %Tracks.get_children():
		if track.node_path == node_path:
			return track
	
	undo_.create_action("add track")
	
	var track_name := preload("res://tools/track_name.tscn").instantiate()
	
	track_name.get_node("Delete").pressed.connect(_erase_track.bind(track_name))

	var track := preload("res://tools/track.tscn").instantiate()

	track.custom_minimum_size.y = 32
	track.custom_minimum_size.x = 1024
	track.node_path = node_path
	track.gui_input.connect(_track_gui_input.bind(track))
	track.track_name = track_name

	track_name.get_node("Value").text = node_path
	track_name.get_node("Value").text_changed.connect(_track_value_changed.bind(track))



	undo_.add_do_reference(track_name)
	undo_.add_do_reference(track)
	undo_.add_do_method(%TrackNames.add_child.bind(track_name))
	undo_.add_do_method(%Tracks.add_child.bind(track))
	undo_.add_undo_method(%TrackNames.remove_child.bind(track_name))
	undo_.add_undo_method(%Tracks.remove_child.bind(track))

	undo_.commit_action()
	
	return track

func _track_value_changed(new_text, track) -> void:
	track.node_path = NodePath(new_text)

func _erase_track(track_name:Control) -> void:
	undo_.create_action("erase track")

	undo_.add_do_method(%TrackNames.remove_child.bind(track_name))
	undo_.add_undo_method(%TrackNames.add_child.bind(track_name))
	undo_.add_undo_reference(track_name)
	
	var track = %Tracks.get_child(track_name.get_index())
	undo_.add_do_method(%Tracks.remove_child.bind(track))
	undo_.add_undo_method(%Tracks.add_child.bind(track))
	undo_.add_undo_reference(track)

	undo_.commit_action()

func _new_track_pressed():
	add_track()

func set_time_range_(range:Vector2i) -> void:
	if range.x >= range.y:
		range.x = range.y - 1
		
	if range.x < 0:
		range.x = 0
		
	if range.y <= range.x:
		range.y = range.x + 1

	time_range_ = range
	%Time.position.x = range.x * 32
	%Time.size.x = range.y * 32 - %Time.position.x

func play():
	playing_ = true

func _process(delta) -> void:
	if not playing_:
		return
	
	var time = time_
	time_ += delta * 16.0
	
	if floor(time_) <= floor(time):
		return

	var t := int(floor(time_))
	t = t % (time_range_.y - time_range_.x) + time_range_.x
	
	%Cursor.position.x = t * 32.0

	for track in %Tracks.get_children():
		var note = track.queue.get(t)
		if note:
			bang.emit(track.node_path, note.value)

func save() -> void:
	var res := []

	for track in %Tracks.get_children():
		res.push_back(track.serialize())

	var file := FileAccess.open("res://junk/beat.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(res))

func reload() -> void:
	var file := FileAccess.open("res://junk/beat.json", FileAccess.READ)
	if not file:
		return

	var text := file.get_as_text()
	var res = JSON.parse_string(text)
	
	for track in res:
		var track_node = add_track(track.name)
		
		for note in track.notes:
			var key = preload("res://tools/bang.tscn").instantiate()
			connect_key_signals_(key)
			key.time = note.time
			key.type = note.get("type", 0)
			key.from_value = note.from_value
			key.value = note.value
			key.length = note.length
			track_node.add_child(key)
		
		track_node.invalidate_queue()

func _save_pressed():
	save()

func _time_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if %Time.get_local_mouse_position().x < %Time.size.x * 0.5:
				tool_ = Tool.resizing_time_begin
			else:
				tool_ = Tool.resizing_time_end
