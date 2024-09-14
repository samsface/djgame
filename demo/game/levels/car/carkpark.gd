extends Node3D

signal any_input

func _ready() -> void:
	Bus.audio_service.open_patch("res://junk/radio.pd")
	Bus.audio_service.set_metro(((60000.0 / 132.0) / 4.0))
	

	
	%Radio.on = false
	
	Bus.camera_service.look_speed = 0.1
	
	%Mano.visible = false
	

	
	
	Bus.points_service.good_boy.value = 0.5
	Bus.points_service.good_boy.visible = false
	
	%BeatPlayerHost.get_node("%scene/%FirstCameraAngle").begin()
	

	%Radio/%GodRay.intensity = 0.0
	
	#var begin_state := PapaSpeach.new()
	#add_child(begin_state)
	
	#%BeatPlayerHost._play_pressed()
	
	add_child(PapaSpeach.new())


class PapaSpeach extends State:
	func _ready():
		Bus.camera_service.look_speed = 0.1
		%Dad.talking = 0.2
		%Dad.emotion = CharacterFace.Emotion.NEUTRAL

		
		%Camera.free_walk = true	
		%Camera.no_walk = true
		%Camera.walk_height = 0.1
	
		%Camera.look_x_range = Vector2(-10, 20)
		%Camera.look_y_range = Vector2(-90, -90)
		%Dad.transform = %PapaMarkerForIntro.transform
		%Subtitle.bars = %Subtitle.dialog_bar_length
	
	
		%Subtitle.text = "Papa: Son... I go ta pay me taxes."
		await ui_accept
		%Subtitle.text = "Now you be a gud boy."
		
		await %Subtitle.finished

		await ui_accept
		%Subtitle.text = "So ya grow up to be somtin gud for da world."
		await ui_accept
		%Subtitle.text = "Like a [shake]doctor[/shake]."
		%Dad.emotion = CharacterFace.Emotion.VERY_HAPPY
		await ui_accept
		%Subtitle.text = "But promise me..."
		%Dad.emotion = CharacterFace.Emotion.NEUTRAL
		await ui_accept
		%Subtitle.text = "Don't play with da radio again."
		%Dad.emotion = CharacterFace.Emotion.CONFUSED
		await ui_accept
		%Subtitle.text = "Playing with da radio is bad. Ya understand?"
		%Dad.emotion = CharacterFace.Emotion.NEUTRAL
		await ui_accept
		%Subtitle.text = "Gud boy."
		%Dad.emotion = CharacterFace.Emotion.VERY_HAPPY
		await ui_accept
		%Dad.visible = false
		%Subtitle.text = ""
		
		good_boy_meter_gag()

	func good_boy_meter_gag():
		Bus.points_service.good_boy.value = 0
		
		await delay(0.1)
		
		Bus.points_service.good_boy.visible = true
		
		Bus.points_service.center(Bus.points_service.good_boy)

		var t := create_tween()
		t.tween_property(Bus.points_service.good_boy, "scale", Bus.points_service.good_boy.scale * 1.1, 0.1)
		t.tween_property(Bus.points_service.good_boy, "scale", Bus.points_service.good_boy.scale, 0.1)
		t.tween_property(Bus.points_service.good_boy, "value", 0.5, 1.0).from(0)
		await t.finished
		
		Bus.points_service.label.text = "Gud BoY meter unlocked!"
		Bus.points_service.center(Bus.points_service.label, Vector2.UP * 128.0)
	
		await ui_accept
		
		Bus.points_service.label.text = "Doctor achievement started!"
		Bus.points_service.good_boy.get_node("%DoctorIcon").visible = true

		await ui_accept
		
		Bus.points_service.label.text = ""
		
		Bus.points_service.good_boy.sort = true
		
		await delay(3.0)

		move_to(EyeRadio.new())

class EyeRadio extends State:
	func _ready() -> void:
		%Mano.visible = true
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(%Mano, "position:y", %Mano.position.y, 1.0).from(%Mano.position.y - 0.5)
		tween.tween_interval(0.2)
		%Mano.emotion = CharacterFace.Emotion.NEUTRAL
		%Mano.talking = 0.4
		await tween.finished

		%Subtitle.text = "Mano: Hey! Wanna play radio?"
		%Mano.emotion = CharacterFace.Emotion.NEUTRAL

		%Radio/%GodRay.intensity = 0.0
		%Camera.look_x_range = Vector2(-70, 25)
		%Camera.look_y_range = Vector2(-123, 123)
		
		var t := create_tween()
		t.tween_property(%Radio/%GodRay, "intensity", 0.2, 0.2)
  

	func _physics_process(delta):
		if %Radio.mouse_over:
			if Bus.points_service.good_boy.value > 0.2:
				Bus.points_service.good_boy.value  -= delta * 0.05#
				%Camera.position = %Camera.position.move_toward(%HolyCarRadioAngle.position, delta * 0.1)
			else:
				move_to(PushButtons.new())
				
class PushButtons extends State:
	func _ready() -> void:
		%Subtitle.text = "[center][font_size=64]Mano: Push the buttons! Do it! [1] [2] [3] [4][/font_size][/center]"
		
	func _physics_process(delta: float) -> void:
		if Bus.points_service.good_boy.value < 0.06:
			move_to(PushOnButton.new())
		
	func _input(event: InputEvent) -> void:
		for key in ["1", "2", "3", "4"]:
			if event.is_action_pressed(key):
				Bus.points_service.good_boy.value -= 0.01

class PushOnButton extends State:
	func _ready() -> void:
		var t = Bus.camera_service.camera_.global_transform
		t.origin -= Bus.camera_service.get_parent().global_position
		t = t.rotated(Vector3.UP, -Bus.camera_service.get_parent().global_rotation.y)

		%Subtitle.text = "[center][font_size=64]Mano: Wai... you gotta turn it on: [0][/font_size][/center]"
		%Camera.free_walk = false
		%BeatPlayerHost.get_node("%scene/%RadioCameraAngle").set("from", t)
		%BeatPlayerHost.get_node("%scene/%RadioCameraAngle").begin()

	func _input(event: InputEvent) -> void:
		if event.is_action_pressed("0"):
			
			Bus.points_service.add_points("good_boy", -0.01)
			%BeatPlayerHost._play_pressed()
			%Subtitle.text = ""
				
			var t := create_tween()
			t.parallel()
			t.tween_property(Bus.bars, "bars", 0.0, 1.0)
			t.tween_property(%Radio/%GodRay, "intensity", 0.0, 0.2)
##
			t.finished.connect(queue_free)


var mini_game_
func begin_foot_ball_mini_game() -> void:
	mini_game_ = preload("res://game/levels/car/football/mini_game_viewport.tscn").instantiate()
	add_child(mini_game_)

func end_foot_ball_mini_game() -> void:
	mini_game_.queue_free()
	
func move_papa(x) -> void:
	%Dad.transform = get_node(x).transform
	%Dad.visible = true
	%Dad.emotion = CharacterFace.Emotion.ANGRY
	%Dad.talking = 1.0

func _input(e:InputEvent) -> void:
	if e.is_action_pressed("debug_next_level"):
		get_tree().change_scene_to_file("res://game/daft_house_level.tscn")
