extends Control

signal bang

var undo_ = UndoRedo.new()

var playing := false

func _ready():
	undo_.clear_history()
	%TrackNames.undo = undo_
	%Inspector.undo = undo_
	%PianoRoll.undo = undo_
	%PianoRoll.row_pressed.connect(_piano_roll_pressed)
	%PianoRoll.bang.connect(_piano_roll_bang)
	%PianoRoll.selection_changed.connect(_piano_roll_selection_changed)
	
	reload()

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("redo"):
		undo_.redo()
	elif event.is_action_pressed("undo"):
		undo_.undo()

func _piano_roll_bang(item:Control, idx:int) -> void:
	$Virtual2.node = item

	var method:StringName
	if $Virtual2.type == 0:
		method = &"bang"
	elif $Virtual2.type == 1:
		method = &"slide" 
	else:
		method = item.get("method")
	
	var args := [
		%TrackNames.get_track_node_path(idx),
		$Virtual2.length / %PianoRoll.tempo
	]
	
	for property_name in %Inspector.include_list:
		if property_name in item:
			args.push_back(item.get(property_name))

	bang.emit(method, args)

func _piano_roll_pressed(row_idx:int, pos:Vector2i) -> void:
	var note = preload("bang.tscn").instantiate()
	note.position.x = pos.x
	%PianoRoll.add_item(note, row_idx)

func _piano_roll_selection_changed(selection:Array) -> void:
	if not selection:
		%Inspector.node = null
		return

	%Inspector.node = selection[0]

func play():
	playing = true
	%PianoRoll.playing = true

func stop():
	%PianoRoll.time_ = 0.0
	playing = false
	%PianoRoll.playing = false

func add_track(node_path) -> void:
	%TrackNames.add_track(node_path)

func save() -> void:
	var state := {
		time_range = %PianoRoll.time_range,
		tracks = []
	}
	
	var track_names = %TrackNames.get_all_track_names()
	var piano_roll = %PianoRoll.get_queue()

	for i in range(piano_roll.size()):
		var track := {
			name = track_names[i],
			notes = []
		}

		for note in piano_roll[i]:
			track.notes.push_back(%Inspector.to_dict(note))

		state.tracks.push_back(track)

	var file := FileAccess.open("res://junk/beat.json", FileAccess.WRITE)
	file.store_string(var_to_str(state))

func reload() -> void:
	var file := FileAccess.open("res://junk/beat.json", FileAccess.READ)
	if not file:
		return

	var dict:Dictionary = str_to_var(file.get_as_text())
	%PianoRoll.time_range = dict.time_range
	
	for i in dict.tracks.size():
		add_track(dict.tracks[i].name)
		
		for note in dict.tracks[i].notes:
			var n:Control
			if int(note.type) == 0:
				n = preload("bang.tscn").instantiate()
			elif int(note.type) == 1:
				n = preload("slide.tscn").instantiate()
			elif int(note.type) == 2:
				n = preload("method.tscn").instantiate()

			$Virtual.node = n
			var grid_size = %PianoRoll.grid_size
			Dictializer.from_dict(note, $Virtual)
			Dictializer.from_dict(note, n)
			%PianoRoll.add_item(n, i, false)

func _save_pressed():
	save()

func _play_pressed():
	%PianoRoll.play()

func change_type_(node, new_type:int) -> void:
	var current_type = node.get_meta("__type__", 0)
	
	if new_type == current_type:
		return

	if not node.get_parent():
		node.set_meta("__type__", new_type)
		return
		
	var row_idx = node.get_parent().get_index() - 2
		
	%PianoRoll.remove_item(node)
	
	var n:Control
	if int(new_type) == 0:
		n = preload("res://tools/bang.tscn").instantiate()
	elif int(new_type) == 1:
		n = preload("res://tools/slide.tscn").instantiate()
	elif int(new_type) == 2:
		n = preload("res://tools/method.tscn").instantiate()
	
	%PianoRoll.add_item(n, row_idx)

	%Inspector.node = n
	%Inspector.copy_all_possible_property_values(node, n)
	n.size = node.size
	n.position = node.position

	n.set_meta("__type__", new_type)


	#node.queue_free()
