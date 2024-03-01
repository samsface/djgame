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
	
func _input(event:InputEvent) -> void:
	if event.is_action_pressed("redo"):
		undo_.redo()
	elif event.is_action_pressed("undo"):
		undo_.undo()

func _piano_roll_bang(item:Control, idx:int) -> void:
	bang.emit(%TrackNames.get_track_node_path(idx), item.value)

func _piano_roll_pressed(row:Control) -> void:
	var note = preload("res://tools/bang.tscn").instantiate()
	note.position.x = row.get_local_mouse_position().x
	%PianoRoll.add_item(note, row)

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
		#var track_node = add_track(track.name)
		var track_node = null
		
		for note in track.notes:
			var key = preload("res://tools/bang.tscn").instantiate()
			#connect_key_signals_(key)
			key.time = note.time
			key.type = note.get("type", 0)
			key.from_value = note.from_value
			key.value = note.value
			key.length = note.length
			track_node.add_child(key)
		
		track_node.invalidate_queue()

func _save_pressed():
	save()

func _play_pressed():
	$PianoRoll.play()
