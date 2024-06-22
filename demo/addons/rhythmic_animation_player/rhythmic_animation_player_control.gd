extends Control

@export var root_node:Node
@export var inspector:Node
@export var painting_item:PackedScene

signal seeked
signal begin
signal end

var queue_on_ := []
var queue_off_ := []
var look_ahead_ := 0

var undo_ := UndoRedo.new()

func _ready() -> void:
	$TimelineControl.undo = undo_

func seek(time:float) -> void:
	var t := int(time)
	
	var l = ($TimelineControl.time_range.y - $TimelineControl.time_range.x) 
	
	if time >= $TimelineControl.time_range.y:
		t =  int(t % l)

	t += $TimelineControl.time_range.x
	
	$TimelineControl.caret = t

	for i in queue_off_.size():
		var item = queue_off_[i].get(t)
		if item:
			item.end()

	for i in queue_on_.size():
		var item = queue_on_[i].get(t)
		if item:
			item.begin()

	seeked.emit(t)

func get_look_ahead() -> int:
	return abs(look_ahead_)

func invalidate_queue_() -> void:
	queue_on_.clear()
	queue_off_.clear()

	look_ahead_= 0

	for row in $TimelineControl.get_node("%Rows").get_children():
		var dict_on := {}
		var dict_off := {}
		for item in row.get_children():
			var begin = item.time - item.get_lookahead()
			var end = item.time + item.length

			if item.time < $TimelineControl.time_range.x or item.time > $TimelineControl.time_range.y:
				continue
	
			if begin < $TimelineControl.time_range.x:
				dict_on[$TimelineControl.time_range.y + begin] = item
				#dict_off[time_range.x] = item

			if item.fill():
				for i in range(begin, end - 1):
					dict_on[i] = item
			
			dict_on[begin] = item
			dict_off[end] = item
			
			look_ahead_ = min(look_ahead_, $TimelineControl.time_range.x + begin)
		
		queue_on_.push_back(dict_on)
		queue_off_.push_back(dict_off)

func _row_right_clicked(row_idx:int, time:int) -> void:
	if painting_item:
		var item := painting_item.instantiate()
		item.time = floor(time / $TimelineControl.quantinize_snap) *  $TimelineControl.quantinize_snap
		item.length = $TimelineControl.quantinize_snap
		
		$TimelineControl.add_item(item, row_idx)

func _selection_changed(selection) -> void:
	if not inspector:
		return

	inspector.selection = selection
	
	if Input.is_action_pressed("ctrl"):
		for item in selection:
			if item is RythmicAnimationPlayerControlItem:
				item.begin()

func _row_header_pressed(header) -> void:
	if not inspector:
		return

	inspector.selection = header

func to_dict() -> Dictionary:
	if not inspector:
		return {}

	var res := {
		"name" = name,
		time_range = $TimelineControl.time_range,
		tracks = []
	}
	
	var rows := $TimelineControl.get_node("%Rows")
	var row_headers := $TimelineControl.get_node("%RowHeaders")
	
	for i in rows.get_child_count():
		res.tracks.push_back({ frames = [] })
		res.tracks.back().merge(inspector.scene_to_dict(row_headers.get_child(i).get_node("%Body").get_child(0)))
		
		for item in rows.get_child(i).get_children():
			res.tracks.back().frames.push_back(inspector.scene_to_dict(item))
	
	return res

func from_dict(dict) -> void:
	if not inspector:
		return

	if dict.has("name"):
		name = dict.name
	
	if dict.has("time_range"):
		$TimelineControl.time_range = dict.time_range
	
	for track in dict.get("tracks", []):
		var track_node = _add_row_pressed()
		for property in track:
			track_node.set(property, track[property])

		for frame in track.frames:
			var frame_node = inspector.scene_from_dict(frame)
			$TimelineControl.add_item(frame_node, $TimelineControl.get_row_count() - 1)

	undo_.clear_history()
	
func _add_row_pressed() -> Control:
	var row_header = preload("res://addons/rhythmic_animation_player/rhythmic_animation_player_row_header_control.tscn").instantiate()
	row_header.root_node = root_node
	$TimelineControl.add_row(row_header)
	return row_header

func _changed() -> void:
	invalidate_queue_()
	
func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return

	if event.is_action_pressed("ui_redo"):
		undo_.redo()
	elif event.is_action_pressed("ui_undo"):
		undo_.undo()

func _visibility_changed() -> void:
	if visible:
		inspector.undo = undo_

func _paint_item_selected(index: int) -> void:
	match index:
		0:
			painting_item = preload("res://addons/rhythmic_animation_player/ops/bang.tscn")
		1:
			painting_item = preload("res://addons/rhythmic_animation_player/ops/slide.tscn")
		2:
			painting_item = preload("res://addons/rhythmic_animation_player/ops/method.tscn")
		3:
			painting_item = preload("res://addons/rhythmic_animation_player/ops/dialog.tscn")
		4:
			painting_item = preload("res://addons/rhythmic_animation_player/ops/tween.tscn")
