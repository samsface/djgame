@tool
extends Node3D
class_name Character

var r := randf()

@export_range(0.0, 3.0) var time_scale:float  = 1.0 :
	set(v):
		time_scale = v
		if is_node_ready():
			$AnimationTree.set("parameters/TimeScale/scale", v)
	
@export_range(0.0, 1.0) var filming:float :
	set(v):
		filming = v
		$AnimationTree.set("parameters/Filming/blend_amount", v)

@export_range(0.0, 1.0) var anger:float :
	set(v):
		if anger == 0 and v != 0:
			$AnimationTree.set("parameters/AngerTimeSeek/seek_request", randf() * 19.0)
		anger = v


@export_range(0.0, 1.0) var attention:float :
	set(v):
		attention = v
		if is_node_ready():
			$AnimationTree.set("parameters/Jump/blend_position", attention)

@export_range(0.0, 1.0) var cheer_left:float :
	set(v):
		cheer_left = v
		if is_node_ready():
			$AnimationTree.set("parameters/CheerLeft/blend_amount", cheer_left)

@export_range(0.0, 1.0) var cheer_right:float :
	set(v):
		cheer_right = v
		if is_node_ready():
			$AnimationTree.set("parameters/CheerRight/blend_amount", cheer_right)

@export_range(0.0, 1.0) var clap:float :
	set(v):
		clap = v


@export_range(0.0, 1.0) var tired:float :
	set(v):
		tired = v



var delta_sum_ := 0.0

func _physics_process(delta: float) -> void:
	
	AnimationNodeBlendTree
	delta_sum_ += delta
	
	##if sin(delta_sum_ * 40.0) > 0.9:
	#	speed_scale = 2.0
	#else:
	#	speed_scale = 0.0

	if not Engine.is_editor_hint() or true:
		if has_node("Armature"):
			$Armature.position = $AnimationTree.get_root_motion_position_accumulator()
