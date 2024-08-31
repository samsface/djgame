extends Node3D

signal any_input

func _ready() -> void:
	Bus.audio_service.set_metro(((60000.0 / 132.0) / 4.0))
	
	%Radio.on = false
	
	Bus.camera_service.look_speed = 0.1
	
	%Mano.visible = false
	
	%Dad.talking = 0.2
	%Dad.emotion = CharacterFace.Emotion.NEUTRAL

	#son_im_going_to_pay_my_taxes()
	
	
	%Camera.free_walk = true
	%Camera.no_walk = true
	%Camera.walk_height = 0.1
	
	%Camera.look_x_range = Vector2(-60, 25)
	%Camera.look_y_range = Vector2(-90, -90)
	
	%BeatPlayerHost.get_node("%scene/%FirstCameraAngle").begin()
	
	Bus.points_service.set_points("good_boy", 1.0)

	
	%Radio/%GodRay.intensity = 0.0
	
	var begin_state := PapaSpeach.new()
	add_child(begin_state)


class PapaSpeach extends State:
	func _ready():
		%Subtitle.text = "Papa: Son... I'm going to go pay my taxes."
		await ui_accept
		%Subtitle.text = "Now you be a [color=####00aeec]good boy[/color]."
		
		await %Subtitle.finished
		
		Bus.points_service.show_bar("good_boy", true)
		
		await ui_accept
		
		%Subtitle.text = "You: Yes Papa."

		await ui_accept
		%Subtitle.text = "Papa: So you can grow up to be something useful for society."
		await ui_accept
		%Subtitle.text = "Like a doctor."
		await ui_accept
		%Subtitle.text = "You: Yes Papa."
		await ui_accept
		%Subtitle.text = "Papa: But just promise me one thing."
		await ui_accept
		%Subtitle.text = "Please..."
		await ui_accept
		%Subtitle.text = "Please don't play with the radio again."
		await ui_accept
		%Subtitle.text = "You: I won't papa."
		await ui_accept
		%Subtitle.text = "Papa: Playing with the radio is bad. Do you understand?"
		await ui_accept
		%Subtitle.text = "Kids who play with the radios, grow up to be very bad."
		await ui_accept
		%Subtitle.text = "You: Yes Papa."
		await ui_accept
		%Subtitle.text = "Papa: Good boy."
		await ui_accept
		%Subtitle.text = "I trust you."
		await ui_accept
		%Dad.visible = false
		%Subtitle.text = ""
		
		%Mano.visible = true
		%Mano.talking = 0.4
		
		await ui_accept

		%Subtitle.text = "Mano: Hey! Wanna play radio?"
		await ui_accept
		
		move_to(EyeRadio.new())

class EyeRadio extends State:
	func _ready() -> void:
		%Subtitle.text = ""
		%Radio/%GodRay.intensity = 0.0
		%Camera.look_x_range = Vector2(-70, 25)
		%Camera.look_y_range = Vector2(-123, 123)

	func _physics_process(delta):
		if %Radio.mouse_over:
			if Bus.points_service.get_points("good_boy") > 0.1:
				Bus.points_service.add_points("good_boy", -0.003)
				%Camera.position = %Camera.position.move_toward(%HolyCarRadioAngle.position, delta * 0.1)
			else:
				move_to(PushButtons.new())
				
class PushButtons extends State:
	func _ready() -> void:
		var t := create_tween()
		t.tween_property(%Radio/%GodRay, "intensity", 1.0, 0.2)
		t.tween_property(%Radio/%GodRay, "intensity", 0.0, 0.2).set_delay(0.2)
		t.tween_interval(1.0)
		
		await t.finished
		%Subtitle.text = "[center][font_size=64]Mano: Push the buttons! Do it! [1] [2] [3] [4][/font_size][/center]"
		
	func _physics_process(delta: float) -> void:
		if Bus.points_service.get_points("good_boy") < 0.06:
			move_to(PushOnButton.new())
		
	func _input(event: InputEvent) -> void:
		for key in ["1", "2", "3", "4"]:
			if event.is_action_pressed(key):
				Bus.points_service.add_points("good_boy", -0.01)

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
			t.tween_property(Bus.bars, "bars", 0.0, 1.0)
			t.finished.connect(queue_free)
