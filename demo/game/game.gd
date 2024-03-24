extends Node3D
class_name Level

@onready var guides_ := $Guides
@onready var audio_ := $AudioService
@onready var beat_player_  := %BeatPlayerHost

var tween_:Tween
var rumble := 1.0

func _ready() -> void:
	Camera.level = self
	Camera.guide_service = $Guides
	Camera.audio_service = audio_

	$WorldEnvironment.camera_attributes.dof_blur_far_enabled = true
	
	audio_.connect_to_bang("rumble", _rumble)
	audio_.connect_to_float("clock", _clock)

	for child in get_children():
		if child is Device:
			child.value_changed.connect(_device_nob_value_changed)

func _input(event) -> void:
	if event.is_action("reset"):
		get_tree().reload_current_scene()

func _rumble() -> void:
	Camera.shake(0.7, 0.001 * rumble)
	Camera.rumble.emit()

func _clock(value:float) -> void:
	beat_player_.call_deferred("seek", value)

func _device_nob_value_changed(nob:Nob, new_value:float, old_value:float) -> void:
	#print(nob.get_path())

	if guides_.nob_has_guide(nob):
		return

	return

	if abs(nob.intended_value - new_value) > 0.1:
		nob.reset_to_intended_value()
		$PointsService.no_touch(nob)

func meta(array:Array = []) -> void:
	pass

func clap() -> void:
	$CrowdService.clap()

func _play():
	$phone.free_click = false
	$PointsService.play()
	Camera.cursor.reset()
	audio_.play()
