extends Node3D
class_name Level

@export var patch:String

@onready var guides_ := $Guides
@onready var audio_ := AudioService
@onready var beat_player_  := %BeatPlayerHost

var tween_:Tween
var rumble := 1.0

func _ready() -> void:
	%toykit.look("ZoomOn1")
	
	Bus.level = self


	audio_.connect_to_bang("rumble", _rumble)
	audio_.connect_to_float("clock", _clock)

	for child in get_children():
		if child is Device:
			child.value_changed.connect(_device_nob_value_changed)


	audio_.set_metro(130)
	
	#_play()

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
	%Phone.free_click = false
	$PointsService.play()
	Bus.camera_service.cursor.disabled = false
	audio_.play()

func _died() -> void:
	pass

func stop() -> void:
	%Phone.free_click = true
	audio_.stop()
	
	%Phone.look("Top")
	var stream := preload("res://models/phone/stream/live_stream_app.tscn").instantiate()
	%Phone.get_phone_gui().start_app(stream)
	

	stream.add_message_from_random_user("Love me some acid house")
	stream.add_message_from_random_user("These guys can be play!")
	stream.add_message_from_random_user("I think the ugly one is cute ")
	stream.add_message_from_random_user("Then why call him ugly?")
	stream.add_message_from_random_user("FIRST!")
	stream.add_message_from_random_user("turn it up!!! So good!")
	stream.add_message_from_random_user("Loud music is loud")
	stream.add_message_from_random_user("Love me some acid house")
	
	await get_tree().create_timer(randf()).timeout
	$AudioStreamPlayer.play()
	stream.add_message_from_random_user("Only [shake][b][color=green]missed 1[/color][/b][/shake] time!")
	await get_tree().create_timer(0.8).timeout
	$AudioStreamPlayer.play()
	stream.add_message_from_random_user("He's got [shake][b][color=salmon]C- timing[/color][/b][/shake] though...")
	await get_tree().create_timer(0.8).timeout
	$AudioStreamPlayer.play()
	stream.add_message_from_random_user("Pretty good. [shake][b][color=pink]B+ overall[/color][/b][/shake]")
	
	await get_tree().create_timer(1.0).timeout
	stream.set_reply(0, "[center]thank[/center]")
	stream.set_reply(1, "[center]dismiss[/center]")
	

func _stop() -> void:
	audio_.stop()
