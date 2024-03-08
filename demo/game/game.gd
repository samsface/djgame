extends Node3D

@onready var looking_at_ := $toykit
@onready var guides_ := $Guides
@onready var recorder_ := $Recorder
@onready var beat_player_  := %BeatPlayerHost

var patch_file_handle_ := PDPatchFile.new()
var tween_:Tween

func _ready() -> void:
	beat_player_.bang.connect(_beat_player_bang)
	
	$Recorder.play.connect(func():
		create_tween().tween_property($CrowdService/Chatter, "volume_db", linear_to_db(0.25), 5.0)
		$CrowdService/Clap.play()
		)
	
	$WorldEnvironment.camera_attributes.dof_blur_far_enabled = true
	
	VerletPhysicsServer.height_map = $HeightMapGenerator.data
	VerletPhysicsServer.height_map_origin = $HeightMapGenerator.global_position
	VerletPhysicsServer.height_map_width = $HeightMapGenerator.size

	Engine.max_fps = 144

	#Camera.set_head_position($acid.get_view_position())

	#Camera.smooth_look_at($toykit)
	
	var p = ProjectSettings.globalize_path("res://junk/xxx.pd")

	if not patch_file_handle_.open(p):
		push_error("couldn't open patch")

	PureData.bind("s-clock")
	PureData.bind("s-clock-4")
	PureData.bind("s-rumble")
	PureData.bang.connect(_bang)
	
	for child in get_children():
		if child is Device:
			child.value_changed.connect(_device_nob_value_changed)

func _beat_player_bang(method:StringName, args:Array) -> void:
	if has_method(method):
		callv(method, args)

var i_ = 0

func _bang(r):
	if r == "s-clock":
		i_ += 1
		#if i_ % 2 == 0:
		#	Camera.smooth_look_at(looking_at_, true)
		return
	elif r == "s-rumble":
		Camera.shake(0.7, 0.001)
		Camera.rumble.emit()

var last_ting_

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("noise"):
		Camera.push_look_at($CrowdService, 0, 0)
	elif Input.is_action_just_released("noise"):
		Camera.pop_look_at($CrowdService)
	elif Input.is_action_just_pressed("play"):
		play_()

func play__(node_path, length) -> void:
	PureData.send_bang("r-PLAY")

func play_() -> void:
	if beat_player_.playing:
		beat_player_.stop()
		PureData.send_bang("r-STOP")
		PureData.send_bang("r-RESET")

		for node in guides_.get_children():
			node.queue_free()

	else:
		beat_player_.play()

func slide(nob_path:NodePath, length:float, from_value:float, to_value:float):
	var nob := get_node_or_null(nob_path)
	if not nob:
		return

	Camera.cursor.try_set_position(nob, global_position + Vector3.UP * 0.002)
	Camera.look_at_node(nob.get_parent())

	var pos = nob.get_guide_position_for_value(from_value)
	var d = preload("res://game/guide/slide/slide.tscn").instantiate()
	d.points_service = $PointsService
	d.position = pos
	d.watch(nob, from_value, to_value, length)

	guides_.add_child(d)

func bang(nob_path:NodePath, length:float, value:float, auto:bool):
	var nob := get_node_or_null(nob_path)
	if not nob:
		return

	Camera.cursor.try_set_position(nob, global_position + Vector3.UP * 0.002)
	Camera.look_at_node(nob.get_parent())

	var pos = nob.get_guide_position_for_value(value)
	var d = preload("res://game/guide/bang/bang.tscn").instantiate()
	d.auto = auto
	d.points_service = $PointsService 
	d.position = pos
	d.length = length
	d.watch(nob, value)
	nob.intended_value = value

	guides_.add_child(d)

func wait(node_path:NodePath) -> void:
	pass

func guide_exists_(nob:Nob) -> bool:
	for node in guides_.get_children():
		if node.get_nob() == nob:
			return true

	return false

func _device_nob_value_changed(nob:Nob, new_value:float, old_value:float) -> void:
	print(nob.get_path())

	if guide_exists_(nob):
		return

	if abs(nob.intended_value - new_value) > 0.1:
		nob.reset_to_intended_value()
		$PointsService.no_touch(nob)

func meta(array:Array = []) -> void:
	pass
