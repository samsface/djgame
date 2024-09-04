extends Node3D

var look_dir := Vector2.RIGHT

var walk_cylce: float

var last_step := 0.0

var forced_velocity_h: Vector2

@export var player:bool
@export var move_speed := 1.0
@export var target_position:Vector2
@export var disable_move := false

func _physics_process(delta: float) -> void:
	var input_dir := Vector2(position.x, position.z).direction_to(target_position)
	if player:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	var direction := input_dir.normalized()
	
	if direction and not disable_move:
		forced_velocity_h = forced_velocity_h.move_toward(direction * move_speed, move_speed * 0.1)
		
		if not player:
			var d =  min(Vector2(position.x, position.z).distance_to(target_position), 1.0)
			forced_velocity_h *= d
		
		look_dir = Vector2.from_angle(
				rotate_toward(look_dir.angle(), direction.angle(), delta * 10.0))
				
	
		rotation.y = -look_dir.angle()
				
	else:
		forced_velocity_h = forced_velocity_h.move_toward(Vector2.ZERO, move_speed * 0.1)
	

	walk_cylce += delta * 10.0
	if walk_cylce > last_step + PI:
		last_step += PI
		$AudioStep.play()
	
	var leg_swing = 1.5
	var arm_swing = 0.8
	
	arm_swing *= forced_velocity_h.length() / move_speed
	leg_swing *= forced_velocity_h.length() / move_speed
	
	$Character/Body.rotation.z = sin(walk_cylce + 0.4) * 0.05
	$Character/Body.rotation.y = cos(walk_cylce + 0.4) * 0.05
	$Character/Body.rotation.x = cos(walk_cylce * 2.0 + 0.4) * 0.05 + arm_swing * 0.3
	
	$Character/Body/Head.rotation.x = -arm_swing * 0.1
	
	$Character/LegL.rotation.x = sin(walk_cylce) * leg_swing
	$Character/LegR.rotation.x = -sin(walk_cylce) * leg_swing
	$Character/Body/ArmL.rotation.x = -sin(walk_cylce - 0.6) * arm_swing
	$Character/Body/ArmR.rotation.x = sin(walk_cylce - 0.6) * arm_swing
	
	$Character/Body/ArmR.rotation.z = -arm_swing * 0.5
	$Character/Body/ArmL.rotation.z = arm_swing * 0.5
	
	#if position_h.length() > 15.0:
	#	position_h = position_h.normalized() * 15.0
	
	
	position.x += forced_velocity_h.x * delta
	position.z += forced_velocity_h.y * delta
	#velocity_h = forced_velocity_h
