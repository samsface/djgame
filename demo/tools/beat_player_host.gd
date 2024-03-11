extends VBoxContainer

@export var save_path:String

var state_ = { clips = {} }
var beat_player_
var current_clip_

var playing

func play():
	playing = true
	$TabContainer.get_current_tab_control().play()
	
func stop():
	playing = false
	$TabContainer.get_current_tab_control().stop()

func get_save_file_path_() -> String:
	return save_path

func _ready():
	var file := FileAccess.open(get_save_file_path_(), FileAccess.READ)
	if not file:
		return

	state_ = str_to_var(file.get_as_text())
	
	if not state_:
		state_ = {}
	
	if not state_.has("clips"):
		state_.clips = {}

	for clip_id in state_.clips:
		var bp := preload("beat_player.tscn").instantiate()
		$TabContainer.add_child(bp)
		bp.set_meta("id", clip_id)
		bp.reload(state_.clips[clip_id])

func _play_pressed() -> void:
	play()

func _new_pressed():
	var new_clip_id = randi()
	state_.clips[new_clip_id] = { time_range = Vector2i(0, 16), tracks = [] }
	var bp := preload("beat_player.tscn").instantiate()
	$TabContainer.add_child(bp)
	bp.set_meta("id", new_clip_id)
	bp.reload(state_.clips[new_clip_id])

func _save_pressed():
	var file := FileAccess.open(get_save_file_path_(), FileAccess.WRITE)
	
	for clip in $TabContainer.get_children():
		state_.clips[clip.get_meta("id")] = clip.get_state()
	
	file.store_string(var_to_str(state_))

func _stop_pressed():
	stop()
