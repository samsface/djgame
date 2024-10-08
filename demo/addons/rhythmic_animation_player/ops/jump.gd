extends RythmicAnimationPlayerControlItem

var target_beat_player_

@export var scene:String : 
	set(v):
		scene = v
		invalidate_scene_()

func _ready():
	invalidate_scene_()
	item_rect_changed.connect(invalidate_scene_)

func invalidate_target_beat_player_() -> void:
	if target_beat_player_:
		target_beat_player_.changed.disconnect(redraw_)
	
	target_beat_player_ = get_target_beat_player_()
	if not target_beat_player_:
		# await incase the beat player host hasn't loaded this scene
		await get_tree().process_frame
		target_beat_player_ = get_target_beat_player_()
	
	if target_beat_player_:
		target_beat_player_.changed.connect(redraw_)
	
	redraw_()

func invalidate_scene_() -> void:
	if not is_node_ready():
		await ready

	$Label.text = scene
	invalidate_target_beat_player_()

func redraw_() -> void:
	changed.emit()
	$Polygon2D.position.x = piano_roll_.to_local(-get_lookahead())

func begin() -> void:
	var target_node = get_target_node()
	if target_node:
		target_node.jump(scene)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click:
			get_target_node().show_scene(scene)

func get_lookahead() -> int:
	if not target_beat_player_:
		return 0

	var look_ahead = target_beat_player_.get_look_ahead()

	return look_ahead

func get_target_beat_player_():
	var target_node = get_target_node()
	if not target_node:
		return null
		
	if not target_node.has_method("get_scene"):
		return null

	var scene = target_node.get_scene(scene)
	if not scene:
		return null

	return scene
