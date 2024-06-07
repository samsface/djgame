extends Control

signal finished

var root_node:Node
var undo_ = UndoRedo.new()
var inspector
var painting_scene_:PackedScene = preload("res://tools/bang.tscn")

var hover_tween_ : Tween

var db

@onready var piano_roll_ = %PianoRoll

@export var title:String :
	set(value):
		name = value
	get:
		return name

func _ready():
	%TrackNames.track_focused.connect(_track_focused)
	%TrackNames.track_name_changed.connect(_track_name_changed)
	%TrackNames.undo = undo_
	inspector.undo = undo_
	%PianoRoll.undo = undo_
	%PianoRoll.row_pressed.connect(_piano_roll_pressed)
	%PianoRoll.begin.connect(_piano_roll_begin)
	%PianoRoll.end.connect(_piano_roll_end)
	%PianoRoll.selection_changed.connect(_piano_roll_selection_changed)
	%PianoRoll.finished.connect(func():
		finished.emit()
	)

func _track_focused(track) -> void:
	inspector.virtual_properties = null
	inspector.selection = track

func _track_name_changed(track:Node) -> void:
	var node = root_node.get_node_or_null(track.value)
	%PianoRoll.set_row_target_node(track.get_index(), node)
	
func _input(event:InputEvent) -> void:
	if not is_visible_in_tree():
		return

	if event.is_action_pressed("redo"):
		undo_.redo()
	elif event.is_action_pressed("undo"):
		undo_.undo()

func _piano_roll_begin(item:Control, idx:int) -> void:
	var node_path = %TrackNames.get_track_node_path(idx)
	var node = root_node.get_node(node_path)
	if not node:
		return
		
	var c:String = %TrackNames.get_condition(idx)
	if not c.is_empty():
		var e = Expression.new()
		e.parse(c)
		if not e.execute([], db):
			return

	item.op(db, node, 0)

func _piano_roll_end(item:Control, idx:int) -> void:
	var node_path = %TrackNames.get_track_node_path(idx)
	var node = root_node.get_node(node_path)
	if not node:
		return
		
	var c:String = %TrackNames.get_condition(idx)
	if not c.is_empty():
		var e = Expression.new()
		e.parse(c)
		if not e.execute([], db):
			return

	var length = %Virtual2.length / (1000.0/PureData.metro)

	item.end(db, node)

func _piano_roll_pressed(row_idx:int, pos:Vector2i) -> void:
	var note = painting_scene_.instantiate()
	note.time = floor(piano_roll_.to_world(pos.x) / piano_roll_.quantinize_snap) *  piano_roll_.quantinize_snap
	note.length = piano_roll_.quantinize_snap
	%PianoRoll.add_item(note, row_idx)

func _piano_roll_selection_changed(selection:Array) -> void:
	if not selection:
		inspector.selection = null
		return

	inspector.selection = selection

	if Input.is_action_pressed("ctrl"):
		for node in selection:
			_piano_roll_begin(node, node.get_parent().get_index())

func _gui_input(event):
	return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			$ScrollContainer.scroll_vertical -= 20.0
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			$ScrollContainer.scroll_vertical += 20.0

func seek(time:float) -> void:
	%PianoRoll.seek(time)

func add_track(node_path) -> Control:
	return %TrackNames.add_track(node_path)

func _next_pressed():
	pass

func _split_container_dragged(offset):
	%GhostHSplitContainer.split_offset = offset

func _scroll_horizontal(value):
	%PianoRoll.scroll_horizontal_ratio = value

func _scroll_vertical(value):
	$ScrollContainer.scroll_vertical = value * $ScrollContainer.get_child(0).size.y

func _quant_selected(index):
	%PianoRoll.set_quantinize_snap(index)

func _paint_bang_pressed() -> void:
	%PianoRoll.tool_ = %PianoRoll.Tool.paint

func _paint_id_pressed(id: int) -> void:
	match id:
		0: 
			painting_scene_ = preload("res://tools/bang.tscn")
		1: 
			painting_scene_ = preload("res://tools/slide.tscn")
		2: 
			painting_scene_ = preload("res://tools/method.tscn")
		3: 
			painting_scene_ = preload("res://tools/tween.tscn")
		4: 
			painting_scene_ = preload("res://tools/scene.tscn")
		5: 
			painting_scene_ = preload("res://tools/dialog.tscn")


func to_dict() -> Dictionary:
	var res := {
		tracks = []
	}
	
	for i in %PianoRoll.get_node("%Rows").get_child_count():
		res.tracks.push_back({ frames = [] })
		res.tracks.back().merge(inspector.scene_to_dict(%TrackNames.track_names_.get_child(i)))
		
		for item in %PianoRoll.get_node("%Rows").get_child(i).get_children():
			res.tracks.back().frames.push_back(inspector.scene_to_dict(item))
	
	return res

func from_dict(dict) -> void:
	for track in dict.get("tracks", []):
		var track_node = add_track(track.value)
		for property in track:
			track_node.set(property, track[property])

		for frame in track.frames:
			var frame_node = inspector.scene_from_dict(frame)
			%PianoRoll.add_item(frame_node, track_node.get_index())
