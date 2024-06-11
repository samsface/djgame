extends Control

signal play

@export var save_path:String
@export var root_node:NodePath

var state_ = { clips = {} }
var beat_player_
var current_clip_

var playing

#var node_db := GraphControlNodeDatabase.new()

func seek(time:float) -> void:
	%Tabs.get_child(0).seek(time)

func get_scene(scene) -> Node:
	return %Tabs.get_node_or_null(scene)

func show_scene(scene) -> void:
	var node = %Tabs.get_node_or_null(scene)
	if node:
		%Tabs.current_tab = node.get_index()

func get_save_file_path_() -> String:
	return save_path

func _ready():
	%Inspector.custom_rules.push_back(func(property:Dictionary):
		if property.type == TYPE_STRING and property.name.ends_with("_ex"):
			var ex =  preload("custom_inspector/expression.tscn").instantiate()
			ex.get_control().base_instance = $DB
			return ex
		else:
			return null
		)
		
	var file := FileAccess.open(get_save_file_path_(), FileAccess.READ)
	if not file:
		return

	state_ = str_to_var(file.get_as_text())
	
	for clip in state_:
		_new_pressed()
		%Tabs.get_child(%Tabs.current_tab).from_dict(clip)
		
	%Tabs.current_tab = 0

func _play_pressed() -> void:
	visible = false
	play.emit()

func _debug_pressed():
	play.emit()

func _new_pressed():
	var bp := preload("beat_player.tscn").instantiate()
	bp.name = "scene"
	bp.inspector = %Inspector
	bp.root_node = get_node(root_node)
	%Tabs.add_child(bp)
	%Tabs.current_tab = %Tabs.get_child_count() - 1

func _save_pressed():
	var res := []
	
	for child in %Tabs.get_children():
		res.push_back(child.to_dict())

	var file := FileAccess.open(get_save_file_path_(), FileAccess.WRITE)
	file.store_string(var_to_str(res))
	
func jump(scene) -> void:
	for i in %Tabs.get_child_count():
		if %Tabs.get_child(i).name == scene:
			%Tabs.current_tab = i
			break

func _tab_clicked(tab):
	%Inspector.virtual_properties = null
	%Inspector.selection = %Tabs.get_current_tab_control()

func _duplicate_pressed() -> void:
	var clip = %Tabs.get_child(%Tabs.current_tab).to_dict()
	_new_pressed()
	%Tabs.get_child(%Tabs.current_tab).from_dict(clip)
	


