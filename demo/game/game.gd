extends Node3D
class_name Level

@onready var guides_ := $Guides
@onready var audio_ := $AudioService
@onready var beat_player_  := %BeatPlayerHost

var tween_:Tween
var rumble := 1.0

func _ready() -> void:
	Bus.level = self

	if has_node("WorldEnvironment"):
		$WorldEnvironment.camera_attributes.dof_blur_far_enabled = true
	
	audio_.connect_to_bang("rumble", _rumble)
	audio_.connect_to_float("clock", _clock)

	for child in get_children():
		if child is Device:
			child.value_changed.connect(_device_nob_value_changed)
			
	$PointsService.zero.connect(_died)
	
	#audio_.set_metro(150)

func _inputx(event) -> void:
	if event.is_action("reset"):
		get_tree().reload_current_scene()

func _rumble() -> void:
	Bus.camera_service.shake(0.7, 0.001 * rumble)
	Bus.camera_service.rumble.emit()

func _clock(value:float) -> void:
	audio_.clock = value
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

func play() -> void:
	_play()

func _play():
	$phone.free_click = false
	$PointsService.play()
	Bus.camera_service.cursor.reset()
	audio_.play()

func _died() -> void:
	pass
