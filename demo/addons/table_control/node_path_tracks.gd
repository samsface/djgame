extends Control

signal track_focused

var undo := UndoRedo.new()
@export var piano_roll:Control

var data_ := {}

@onready var track_names_ = $MarginContainer/TrackNames

func add_track(node_path:NodePath = "") -> Node:
	#for track_name in track_names_.get_children():
	#	if track_name.get_node("H/Value").text == str(node_path):
	#		return

	undo.create_action("add track")
	
	var track_name := preload("track_name.tscn").instantiate()
	track_name.get_node("H/Value").focus_entered.connect(_focus_entered.bind(track_name))
	track_name.get_node("H/Delete").pressed.connect(_erase_track.bind(track_name))
	track_name.get_node("H/MoveUp").pressed.connect(_move_track_up.bind(track_name))
	track_name.get_node("H/MoveDown").pressed.connect(_move_track_down.bind(track_name))

	piano_roll.add_row()

	track_name.value = node_path
	
	undo.add_do_reference(track_name)
	undo.add_do_method(track_names_.add_child.bind(track_name))
	undo.add_undo_method(track_names_.remove_child.bind(track_name))

	undo.commit_action()
	
	return track_name
	
func get_track_node_path(idx:int) -> NodePath:
	return track_names_.get_child(idx).value

func get_all_track_names() -> Array:
	var res := []
	for child in track_names_.get_children():
		res.push_back([str(child.value), str(child.condition_ex)])

	return res

func _track_value_changed(new_text, track) -> void:
	track.node_path = NodePath(new_text)

func _focus_entered(track) -> void:
	track_focused.emit(track)

func _erase_track(track_name:Control) -> void:
	undo.create_action("erase track")

	undo.add_do_method(track_names_.remove_child.bind(track_name))
	undo.add_undo_method(track_names_.add_child.bind(track_name))
	undo.add_undo_reference(track_name)

	piano_roll.remove_row(track_name.get_index())

	undo.commit_action()

func _move_track_up(track_name:Control) -> void:
	if track_name.get_index() == 0:
		return
	
	undo.create_action("move track up")
	
	undo.add_do_method(track_name.get_parent().move_child.bind(track_name, track_name.get_index() - 1))
	undo.add_do_method(piano_roll.move_row_up.bind(track_name.get_index()))
	
	undo.add_undo_method(track_name.get_parent().move_child.bind(track_name, track_name.get_index()))
	undo.add_undo_method(piano_roll.move_row_down.bind(track_name.get_index() - 1))

	undo.commit_action()
	
func _move_track_down(track_name:Control) -> void:
	if track_name.get_index() == track_name.get_parent().get_child_count() - 1:
		return
	
	undo.create_action("move track down")
	
	undo.add_do_method(track_name.get_parent().move_child.bind(track_name, track_name.get_index() + 1))
	undo.add_do_method(piano_roll.move_row_down.bind(track_name.get_index()))
	
	undo.add_undo_method(track_name.get_parent().move_child.bind(track_name, track_name.get_index()))
	undo.add_undo_method(piano_roll.move_row_up.bind(track_name.get_index() + 1))

	undo.commit_action()

func set_track_condition(track_idx:int, condition_ex:String) -> void:
	track_names_.get_child(track_idx).condition_ex = condition_ex

func _add_track_pressed():
	add_track()

func get_condition(track_idx:int) -> String:
	return track_names_.get_child(track_idx).condition_ex
