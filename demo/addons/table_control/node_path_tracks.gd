extends VBoxContainer

var undo := UndoRedo.new()
@export var piano_roll:Control

var data_ := {}

@onready var track_names_ = $TrackNames

func add_track(node_path:NodePath = "") -> void:
	for track_name in $TrackNames.get_children():
		if track_name.get_node("Value").text == str(node_path):
			return

	undo.create_action("add track")
	
	var track_name := preload("track_name.tscn").instantiate()
	track_name.get_node("Delete").pressed.connect(_erase_track.bind(track_name))

	piano_roll.add_row()

	track_name.value = node_path
	
	undo.add_do_reference(track_name)
	undo.add_do_method($TrackNames.add_child.bind(track_name))
	undo.add_undo_method($TrackNames.remove_child.bind(track_name))

	undo.commit_action()
	
func get_track_node_path(idx:int) -> NodePath:
	return track_names_.get_child(idx).value
	
func _track_value_changed(new_text, track) -> void:
	track.node_path = NodePath(new_text)

func _erase_track(track_name:Control) -> void:
	undo.create_action("erase track")

	undo.add_do_method($TrackNames.remove_child.bind(track_name))
	undo.add_undo_method($TrackNames.add_child.bind(track_name))
	undo.add_undo_reference(track_name)

	piano_roll.remove_row(track_name.get_index())

	undo.commit_action()

func _add_track_pressed():
	add_track()
