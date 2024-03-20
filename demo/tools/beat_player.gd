extends Control

signal finished

var undo_ = UndoRedo.new()
var inspector

var playing := false

var hover_tween_ : Tween

var db

@onready var piano_roll_ = %PianoRoll

@export var title:String :
	set(value):
		name = value
	get:
		return name

func _ready():
	undo_.clear_history()
	%TrackNames.track_focused.connect(_track_focused)
	%TrackNames.undo = undo_
	inspector.undo = undo_
	%PianoRoll.undo = undo_
	%PianoRoll.row_pressed.connect(_piano_roll_pressed)
	%PianoRoll.bang.connect(_piano_roll_bang)
	%PianoRoll.selection_changed.connect(_piano_roll_selection_changed)
	%PianoRoll.row_mouse_entered.connect(func(row_index:int):
		return
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
		return
		print(row_index)
		if hover_tween_:
			hover_tween_.kill()
		var n = get_node_or_null(%TrackNames.get_track_node_path(row_index))
		if n:
			n.visible = true
	)
	%PianoRoll.finished.connect(func():
		finished.emit()
	)

func _track_focused(track) -> void:
	inspector.virtual_properties = null
	inspector.node = track

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("redo"):
		undo_.redo()
	elif event.is_action_pressed("undo"):
		undo_.undo()

func _piano_roll_bang(item:Control, idx:int) -> void:
	%Virtual2.node = item

	var node_path = %TrackNames.get_track_node_path(idx)
	var node = get_node(node_path)
	if not node:
		return
		
	var c:String = %TrackNames.get_condition(idx)
	if not c.is_empty():
		var e = Expression.new()
		e.parse(c)
		if not e.execute([], db):
			return

	var length = %Virtual2.length / %PianoRoll.tempo

	item.op(db, node, length)

func _piano_roll_pressed(row_idx:int, pos:Vector2i) -> void:
	var note = preload("bang.tscn").instantiate()
	note.position.x = pos.x
	%PianoRoll.add_item(note, row_idx)

func _piano_roll_selection_changed(selection:Array) -> void:
	if not selection:
		inspector.node = null
		return

	inspector.virtual_properties = %Virtual
	inspector.node = selection[0]
	
	if Input.is_action_pressed("ctrl"):
		for node in selection:
			_piano_roll_bang(node, node.get_parent().get_index() - 2)

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
	inspector.virtual_properties = %Virtual
	
	var state := {
		time_range = %PianoRoll.time_range,
		tracks = []
	}

	var track_names = %TrackNames.get_all_track_names()
	var piano_roll = %PianoRoll.get_queue()

	for i in range(piano_roll.size()):
		var track := {
			name = track_names[i][0],
			condition_ex = track_names[i][1],
			notes = []
		}

		for note in piano_roll[i]:
			track.notes.push_back(inspector.to_dict(note))

		state.tracks.push_back(track)

	return state

func reload(dict:Dictionary) -> void:
	%PianoRoll.time_range = dict.time_range
	
	for i in dict.tracks.size():
		add_track(dict.tracks[i].name)
		%TrackNames.set_track_condition(i, dict.tracks[i].get("condition_ex", ""))
		
		
		for note in dict.tracks[i].notes:
			var n:Control
			if int(note.type) == 0:
				n = preload("bang.tscn").instantiate()
			elif int(note.type) == 1:
				n = preload("slide.tscn").instantiate()
			elif int(note.type) == 2:
				n = preload("method.tscn").instantiate()
			elif int(note.type) == 3:
				n = preload("dialog.tscn").instantiate()
			elif int(note.type) == 4:
				n = preload("tween.tscn").instantiate()
				
			%Virtual.node = n
			var grid_size = %PianoRoll.grid_size
			Dictializer.from_dict(note, %Virtual)
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
	elif int(new_type) == 3:
		n = preload("res://tools/dialog.tscn").instantiate()
	elif int(new_type) == 4:
		n = preload("res://tools/tween.tscn").instantiate()
	
	%PianoRoll.add_item(n, row_idx)

	inspector.node = n
	inspector.copy_all_possible_property_values(node, n)
	n.size = node.size
	n.position = node.position

	n.set_meta("__type__", new_type)

func _next_pressed():
	reload({time_range = Vector2i(0, 16), tracks = [] })

func _split_container_dragged(offset):
	%GhostHSplitContainer.split_offset = offset

func _scroll_horizontal(value):
	%PianoRoll.scroll_horizontal = value

func _scroll_vertical(value):
	$ScrollContainer.scroll_vertical = value * $ScrollContainer.get_child(0).size.y

func _quant_selected(index):
	%PianoRoll.set_quantinize_snap(index)
