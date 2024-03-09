extends Control

var undo_ = UndoRedo.new()

var playing := false

var hover_tween_ : Tween

@onready var piano_roll_ = %PianoRoll

func _ready():
	undo_.clear_history()
	%TrackNames.undo = undo_
	%Inspector.undo = undo_
	%PianoRoll.undo = undo_
	%PianoRoll.row_pressed.connect(_piano_roll_pressed)
	%PianoRoll.bang.connect(_piano_roll_bang)
	%PianoRoll.selection_changed.connect(_piano_roll_selection_changed)
	%PianoRoll.row_mouse_entered.connect(func(row_index:int):
		print(row_index)
		if hover_tween_:
			hover_tween_.kill()
		hover_tween_ = create_tween()
		var n = get_node_or_null(%TrackNames.get_track_node_path(row_index))
		if n:
			hover_tween_.set_loops(-1)
			hover_tween_.tween_property(n, "visible", false, 0.1)
			hover_tween_.tween_property(n, "visible", true, 0.3)
	)
	%PianoRoll.row_mouse_exited.connect(func(row_index:int):
		print(row_index)
		if hover_tween_:
			hover_tween_.kill()
		var n = get_node_or_null(%TrackNames.get_track_node_path(row_index))
		if n:
			n.visible = true
	)

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("redo"):
		undo_.redo()
	elif event.is_action_pressed("undo"):
		undo_.undo()

func _piano_roll_bang(item:Control, idx:int) -> void:
	$Virtual2.node = item

	var args := []

	var method:StringName
	if $Virtual2.type == 0:
		method = &"bang"
		args.push_back($Virtual2.length / %PianoRoll.tempo)
	elif $Virtual2.type == 1:
		method = &"slide" 
		args.push_back($Virtual2.length / %PianoRoll.tempo)
	else:
		var method_args_generic = item.get("method").split(" ")
		method = method_args_generic[0]
		for i in range(1, method_args_generic.size()):
			args.push_back(int(method_args_generic[i]))

	var node_path = %TrackNames.get_track_node_path(idx)

	for property_name in %Inspector.include_list:
		if property_name == "method":
			continue
		if property_name in item:
			args.push_back(item.get(property_name))

	var node = get_node(node_path)
	if not node:
		return
	
	if not node.has_method(method):
		return
	
	node.callv(method, args)

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
	%PianoRoll.cursor.position.x = 0

func add_track(node_path) -> void:
	%TrackNames.add_track(node_path)

func get_state() -> Dictionary:
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

	return state

func reload(dict:Dictionary) -> void:
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

func _next_pressed():
	reload({time_range = Vector2i(0, 16), tracks = [] })
