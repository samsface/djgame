extends Node3D

@onready var looking_at_ := $toykit
@onready var guides_ := $Guides
@onready var recorder_ := $Recorder

var patch_file_handle_ := PDPatchFile.new()
var tween_:Tween

func _ready() -> void:
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

func follow(nob_path:NodePath, begin_time:float, end_time:float, from_value:float, to_value:float, meta:Array = []):
	var nob := get_node_or_null(nob_path)
	if not nob:
		return
		
	var phrase_over = "phrase_over" in meta

	var pos = nob.get_guide_position_for_value(from_value)
	var d = preload("res://game/guide/slide/slide.tscn").instantiate()
	d.points_service = $PointsService
	d.position = pos
	d.watch(nob, from_value, to_value, (end_time - begin_time) / $Recorder/AnimationPlayer.speed_scale)

	guides_.add_child(d)

func test(nob_path:NodePath, key_time:float, value:float, meta:Array):
	var nob := get_node_or_null(nob_path)
	if not nob:
		return
		
	var phrase_over = "phrase_over" in meta

	var pos = nob.get_guide_position_for_value(value)
	var d = preload("res://game/guide/bang/bang.tscn").instantiate()
	d.points_service = $PointsService 
	d.position = pos
	d.watch(nob, value)
	nob.intended_value = value

	guides_.add_child(d)

func guide_exists_(nob:Nob) -> bool:
	for node in guides_.get_children():
		if node.get_nob() == nob:
			return true

	return false

func _device_nob_value_changed(nob:Nob, new_value:float, old_value:float) -> void:
	if not recorder_.playing_:
		return

	if guide_exists_(nob):
		return

	if abs(nob.intended_value - new_value) > 0.1:
		nob.reset_to_intended_value()
		#bad_(nob.get_nob_position() + Vector3.UP * 0.01, -1)

func meta(array:Array = []) -> void:
	pass
