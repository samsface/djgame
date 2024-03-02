extends Control

signal bang

var undo_ = UndoRedo.new()

func _ready():
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
	bang.emit({
		type = item.type,
		from_value = item.from_value,
		value = item.value,
		length = item.length,
		node_path = %TrackNames.get_track_node_path(idx)
	})

func _piano_roll_pressed(row_idx:int, pos:Vector2i) -> void:
	var note = preload("res://tools/bang.tscn").instantiate()
	note.position.x = pos.x
	%PianoRoll.add_item(note, row_idx)

func _piano_roll_selection_changed(selection:Array) -> void:
	if not selection:
		%Inspector.node = null
		return

	%Inspector.node = selection[0]

func play():
	pass
	#playing_ = true

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
			track.notes.push_back(Dictializer.to_dict(note, ["type", "time", "type", "length", "from_value", "value"]))
			
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
			var n := preload("bang.tscn").instantiate()
			Dictializer.from_dict(note, n)
			%PianoRoll.add_item(n, i)

func _save_pressed():
	save()

func _play_pressed():
	$PianoRoll.play()
