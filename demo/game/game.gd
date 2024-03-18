extends Node3D
class_name Level

@onready var looking_at_ := $toykit
@onready var guides_ := $Guides
@onready var recorder_ := $Recorder
@onready var beat_player_  := %BeatPlayerHost

var patch_file_handle_ := PDPatchFile.new()
var tween_:Tween
var rumble := 1.0

func _ready() -> void:
	Camera.level = self
	Camera.guide_service = $Guides

	$WorldEnvironment.camera_attributes.dof_blur_far_enabled = true
	
	#VerletPhysicsServer.height_map = $HeightMapGenerator.data
	#VerletPhysicsServer.height_map_origin = $HeightMapGenerator.global_position
	#VerletPhysicsServer.height_map_width = $HeightMapGenerator.size


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
		Camera.shake(0.7, 0.001 * rumble)
		Camera.rumble.emit()

var last_ting_

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("noise"):
		Camera.push_look_at($CrowdService, 0, 0)
	elif Input.is_action_just_released("noise"):
		Camera.pop_look_at($CrowdService)
	elif Input.is_action_just_pressed("play"):
		play_()
	elif Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func play():
	play_()

func play__() -> void:
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

	return

	if abs(nob.intended_value - new_value) > 0.1:
		nob.reset_to_intended_value()
		$PointsService.no_touch(nob)

func meta(array:Array = []) -> void:
	pass

func clap() -> void:
	$CrowdService.clap()
