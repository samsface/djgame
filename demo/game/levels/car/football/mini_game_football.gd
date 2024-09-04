extends Node3D

# 14 seconds of fun

var delta_sum_ := 0.0

var ball_grabbed_ := false
var ball_kicked_ := false

func _ready() -> void:
	add_child(GetTheBall.new())
	add_child(PapaChaseWait.new())
	
		
	%Papa.target_position = Vector2(%Papa.position.x, %Papa.position.y)
	%Mano.target_position = Vector2(%Mano.position.x, %Mano.position.y)

var camera_track_player_ := true
var mano_track_player_ := true

func _physics_process(delta: float) -> void:
	delta_sum_ += delta
	
	if camera_track_player_:
		$CameraBase.position.x = lerp($CameraBase.position.x, $Character.position.x, delta * 10.0)
		$CameraBase.position.z = lerp($CameraBase.position.z, $Character.position.z, delta * 10.0)
		
	if mano_track_player_:
		%Mano.target_position.x  = %Character.position.x
		%Mano.target_position.y  = %Character.position.z

class PapaChaseWait extends State:
	func _enter_tree() -> void:
		owner = get_parent()

	func _ready() -> void:
		%Papa.disable_move = true
		%Mano.disable_move = true
		%Character.disable_move = true
		
		get_parent().camera_track_player_ = false

		
		%Camera3D.global_transform = %StartCameraMarker.global_transform
		
		#await  delay(0.2)
		
		
		var t := create_tween()
		t.set_parallel()
		t.tween_property(%Camera3D, "global_transform", %ManoCamera.global_transform, 0.25)
		%Subtitle.bars = %Subtitle.dialog_bar_length
		%Subtitle.text = "Mano: [shake]RUN![/shake]"
	
	func _physics_process(delta: float) -> void:
		if Input.get_vector("move_left", "move_right", "move_forward", "move_backward"):
			move_to(PapaChase.new())

class PapaChase extends State:
	func _enter_tree() -> void:
		owner = get_parent()
		
	func _ready() -> void:
		get_parent().camera_track_player_ = true
		delay(4.0).connect(back_to_the_car)
		%Papa.disable_move = false
		%Mano.disable_move = false
		%Character.disable_move = false
		
		%Subtitle.text = ""
		var t := create_tween()
		t.set_parallel()
		t.tween_property(%Subtitle, "bars", 0, 0.25)
		t.tween_property(%Camera3D, "transform",  Transform3D(), 0.25)

	func _physics_process(delta: float) -> void:
		%Papa.target_position = Vector2(%Character.position.x, %Character.position.z)
		
	func back_to_the_car() -> void:
		var s = %Camera3D.transform

		get_parent().camera_track_player_ = false
		%Papa.disable_move = true
		%Mano.disable_move = true
		%Character.disable_move = true

		var t := create_tween()
		t.set_parallel()
		t.tween_property(%Subtitle, "bars", %Subtitle.dialog_bar_length, 0.25)
		t.tween_property(%Camera3D, "global_transform",  %ManoCamera.global_transform, 0.25)

		await  t.finished
		
		%Subtitle.text = "Mano: [shake]Let's lock da car![/shake]"
		await %Subtitle.finished

		await delay(1.0)
		
		%Subtitle.text = ""
		
		%Papa.disable_move = false
		%Mano.disable_move = false
		get_parent().mano_track_player_ = false
		%Mano.target_position.x = %car_hatchback2.position.x
		%Mano.target_position.y = %car_hatchback2.position.z
		%Character.disable_move = false

		t = create_tween()
		t.set_parallel()
		t.tween_property(%Subtitle, "bars", 0, 0.25)
		t.tween_property(%Camera3D, "transform",  s, 0.25)
		

		await  t.finished
		
		get_parent().camera_track_player_ = true

		
		%Character.move_speed = 50.0
		%Papa.move_speed = 40.0
		
		
		move_to(PapaChaseToCar.new())

class PapaChaseToCar extends State:
	var b_ := false
	
	func _enter_tree() -> void:
		owner = get_parent()

	func _physics_process(delta: float) -> void:
		%Papa.target_position = Vector2(%Character.position.x, %Character.position.z)
		
		if get_parent().delta_sum_ > 9.5:
			if not b_:
				b_ = true
				var d = %Character.position.distance_to(%car_hatchback2.position)
				%Character.move_speed = d / 1.0
			
			%Character.player = false
			%Character.target_position.x = %car_hatchback2.position.x
			%Character.target_position.y = %car_hatchback2.position.z

class GetTheBall extends State:
	func _enter_tree() -> void:
		owner = get_parent()
	
	func _physics_process(delta: float) -> void:
		if %Character.position.distance_to(%Ball.position) < 3.0:
			move_to(KickTheBall.new())

class KickTheBall extends State:
	var delta_sum_ := 0.0
	
	func _enter_tree() -> void:
		owner = get_parent()
	
	
	func _physics_process(delta: float) -> void:
		delta_sum_ += delta

		if Input.is_action_just_pressed("space"):
			move_to(Goal.new())
			return
		
		var s = (sin(delta_sum_ * 10.0) + 1.0) * 0.5
		s *= %Character.forced_velocity_h.length() * 0.02
		s += 0.8
		
		%Ball.global_position.y = 0.5
		%Ball.global_position.x = %Character.global_position.x + Vector2.from_angle(%Character.rotation.y).x * 2.0 * s
		%Ball.global_position.z = %Character.global_position.z - Vector2.from_angle(%Character.rotation.y).y * 2.0 * s

class Goal extends State:
	func _enter_tree() -> void:
		owner = get_parent()
	
	
	var kick_direction_ := Vector2.ZERO
	
	func _ready() -> void:
		kick_direction_.x = Vector2.from_angle(%Character.rotation.y).x
		kick_direction_.y = Vector2.from_angle(%Character.rotation.y).y

	func _physics_process(delta: float) -> void:
		%Ball.global_position.x += kick_direction_.x * delta * 150.0
		%Ball.global_position.z -= kick_direction_.y * delta * 150.0 
