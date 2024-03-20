extends VBoxContainer

@export var save_path:String

var state_ = { clips = {} }
var beat_player_
var current_clip_

var playing

#var node_db := GraphControlNodeDatabase.new()

func play():
	playing = true
	%TabContainer.get_current_tab_control().play()

func stop():
	playing = false
	%TabContainer.get_current_tab_control().stop()

func get_save_file_path_() -> String:
	return save_path

func _ready():
	#$SubViewportContainer.patch_.node_selected.connect(_graph_node_selected)
	#$SubViewportContainer.patch_.node_db_ = node_db
	
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
		bp.inspector = %Inspector
		bp.name = clip_id
		bp.db = $DB
		%TabContainer.add_child(bp)
		%TabContainer.set_tab_icon(bp.get_index(), preload("tab_icon.png"))
		bp.set_meta("id", clip_id)
		bp.reload(state_.clips[clip_id])

	%Inspector.custom_rules.push_back(func(property:Dictionary):
		if property.type == TYPE_STRING and property.name.ends_with("_ex"):
			var ex =  preload("custom_inspector/expression.tscn").instantiate()
			ex.get_control().base_instance = $DB
			return ex
		else:
			return null
		)

func _graph_node_selected(node) -> void:
	if not node:
		return
	
	if not node.node_model_:
		return
		
	if node.node_model_.specialized == preload("res://tools/graph/scene.tscn"):
		for child in %TabContainer.get_children():
			if child.name == node.node_model_.title:
				%TabContainer.current_tab = child.get_index()
				break

func _play_pressed() -> void:
	play()

func _new_pressed():
	var new_clip_id = randi()
	state_.clips[new_clip_id] = { time_range = Vector2i(0, 16), tracks = [] }
	var bp := preload("beat_player.tscn").instantiate()
	bp.name = "scene"
	bp.inspector = %Inspector
	%TabContainer.add_child(bp)
	bp.set_meta("id", new_clip_id)
	bp.reload(state_.clips[new_clip_id])
	#node_db.add(bp.name, preload("res://tools/graph/scene.tscn"))

func _save_pressed():
	state_ = { clips = {} }

	for clip in %TabContainer.get_children():
		state_.clips[clip.name] = clip.get_state()

	var file := FileAccess.open(get_save_file_path_(), FileAccess.WRITE)
	file.store_string(var_to_str(state_))

func _stop_pressed():
	stop()

func jump(scene) -> void:
	stop()
	for i in %TabContainer.get_child_count():
		if %TabContainer.get_child(i).name == scene:
			%TabContainer.current_tab = i
			play()
			break

func _tab_clicked(tab):
	%Inspector.virtual_properties = null
	%Inspector.node = %TabContainer.get_current_tab_control()
