extends Node3D
class_name Level

@export var patch:String
@export var autoplay := false

@onready var guides_ := $Guides
@onready var audio_ := AudioService
@onready var beat_player_  := %BeatPlayerHost

var tween_:Tween
var rumble := 0.0 

func _ready() -> void:
	#Bus.level = self

	Bus.audio_service.open_patch("res://junk/xxx.pd")

	for child in get_children():
		if child is Device:
			child.value_changed.connect(_device_nob_value_changed)


	audio_.set_metro(123.0)
	
	if autoplay:
		_play()
	$Camera.looky(Vector3(-0.0147195002064109, 0.1273230016231537, -0.327578991651535), Vector3(-0.9006010293960571, -0.2513279914855957, 0), 0.1)

	Bus.points_service.good_boy.value = 0.5
	Bus.points_service.center(Bus.points_service.good_boy)
	
	Bus.guide_service.hit.connect(_guide_hit)

func _guide_hit() -> void:
	var tween := create_tween()
	tween.parallel()
	tween.tween_property($GardenPretty/SpotLight3D5, "light_energy", 1.0, 0.1)
	tween.tween_property($GardenPretty/SpotLight3D6, "light_energy", 1.0, 0.1)
	var chain := tween.chain()
	chain.tween_property($GardenPretty/SpotLight3D5, "light_energy", 0.0, 0.1)
	chain.tween_property($GardenPretty/SpotLight3D6, "light_energy", 0.0, 0.1)

func _physics_process(delta: float) -> void:
	if int(floor(audio_.clock)) % 4 == 0:
		Bus.audio_service.call_with_latency(force_rumble)

func force_rumble() -> void:
	Bus.camera_service.shake(0.7, 0.001 * rumble)
	Bus.camera_service.rumble.emit()


func table_jump() -> void:
	var t := create_tween()
	t.tween_property($Table/NorthFace, "position:y", 0.02, 0.05)
	t.tween_property($Table/NorthFace, "position:y", 0.0, 0.1).set_delay(0.05)

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
	#Bus.camera_service.cursor.disabled = false
	audio_.play()

func _died() -> void:
	pass

func stop() -> void:
	%Phone.free_click = true

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
