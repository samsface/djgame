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


	audio_.set_metro(130)

func _input(event) -> void:
	if event.is_action_pressed("debug_switch_env"):
		$GardenOverGrown.visible = not $GardenOverGrown.visible
		$GardenPretty.visible = not $GardenPretty.visible
		
		$WorldEnvironment.sun.light_energy = 1.0 if $GardenOverGrown.visible else 0.0
		$WorldEnvironment.sky.energy_multiplier = 1.0 if $GardenOverGrown.visible else 0.05
		$WorldEnvironment.sun.rotation_degrees = Vector3(-16.4, 0, -35.4) if not $GardenOverGrown.visible else Vector3(-10.4, 0, -35.4)

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
	
	%Phone.look()
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
