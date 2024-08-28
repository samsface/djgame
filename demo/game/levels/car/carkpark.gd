extends Node3D

signal any_input

func _ready() -> void:
	%Radio.on = false
	
	
	%Mano.visible = false
	
	%Dad.talking = 0.2
	%Dad.emotion = CharacterFace.Emotion.NEUTRAL

	son_im_going_to_pay_my_taxes()
	
	
	%Camera.free_walk = true
	%Camera.no_walk = true
	%Camera.walk_height = 0.1
	
	%Camera.look_x_range = Vector2(-60, 25)
	%Camera.look_y_range = Vector2(-90, -90)
	
	%BeatPlayerHost.get_node("%scene/%FirstCameraAngle").begin()
	
	Bus.points_service.set_points("good_boy", 0.2)
	Bus.points_service.show_bar("good_boy", true)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_released():
		if not %BeatPlayerHost.is_visible_in_tree():
			any_input.emit()

func son_im_going_to_pay_my_taxes():
	%Subtitle.text = "[center][font_size=64]LoveDad: Son... I'm going to go pay my taxes.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]Dad: Now you be a good boy.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]You: Yes Papa.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]Dad: So you can grow up to be something useful for society.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]Dad: Like a doctor. Or a scientest.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]You: Yes Papa.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]Dad: But just promise me one thing.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64Love]Dad: Please...[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]Dad: Please don't play with the radio again.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]You: I won't papa.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]Dad: Playing with the radio is bad. Do you understand?[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]Dad: Kids who play with the radio grow up to be something very bad.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]You: Yes Papa.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]Dad: Something completely useless.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]You: Yes Papa.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]Dad: Good boy.[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]Dad: I trust you.[/font_size][/center]"
	await any_input
	%Dad.visible = false
	%Subtitle.text = ""
	
	%Mano.visible = true
	%Mano.talking = 0.4
	
	await any_input

	%Subtitle.text = "[center][font_size=64]Mano: Yur da doin taxes too?[/font_size][/center]"
	await any_input
	%Subtitle.text = "[center][font_size=64]Mano: Let's play radio?[/font_size][/center]"
	await any_input
	
	%Camera.look_x_range = Vector2(-70, 25)
	%Camera.look_y_range = Vector2(-123, 123)
	return
	
	await %Radio.clicked
	%Camera.free_walk = false

	%BeatPlayerHost.get_node("%scene/%RadioCameraAngle").begin()
	
	await %Radio.on_pressed
	
	%BeatPlayerHost.get_node("%scene/%RadioCameraAngle2").begin()

var state_ := "eyeing_radio"

func _physics_process(delta: float) -> void:
	if state_ == "eyeing_radio":
		if %Radio.mouse_over:
			if Bus.points_service.get_points("good_boy") > 0.3:
				Bus.points_service.add_points("good_boy", -0.003)
			else:
				state_ = "looking_at_radio"
				%BeatPlayerHost.get_node("%scene/%RadioCameraAngle").begin()
		else:
			Bus.points_service.add_points("good_boy", 0.001)
	elif state_ == "looking_at_radio":
		pass

		
func begin_good_boy_gag_() -> void:
	Bus.points_service.show_bar("good_boy", true)
