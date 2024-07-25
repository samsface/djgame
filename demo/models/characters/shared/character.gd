@tool
extends Node3D
class_name Character

var r := randf()

@export_range(0.0, 1.0) var speed_scale:float :
	set(v):
		filming = v
		$AnimationTree.set("parameters/Speed/scale", v)

@export_range(0.0, 1.0) var filming:float :
	set(v):
		filming = v
		$AnimationTree.set("parameters/Filming/blend_amount", v)

@export_range(0.0, 1.0) var anger:float :
	set(v):
		AnimationNodeTimeSeek
		if anger == 0 and v != 0:
			$AnimationTree.set("parameters/AngerTimeSeek/seek_request", randf() * 19.0)
		anger = v
		invalidate_attention_()

@export_range(0.0, 1.0) var attention:float :
	set(v):
		attention = v
		invalidate_attention_()

@export_range(0.0, 1.0) var cheer:float :
	set(v):
		cheer = v
		invalidate_attention_()
		
@export_range(0.0, 1.0) var clap:float :
	set(v):
		clap = v
		invalidate_attention_()

@export_range(0.0, 1.0) var tired:float :
	set(v):
		tired = v
		invalidate_attention_()

func invalidate_attention_() -> void:
	var a := []
	var n := 3
	for i in 3:
		a.push_back(clamp((attention - (i/float(n))) * float(n), 0.0, 1.0))

	$AnimationTree.set("parameters/AttentionA/blend_amount", a[0])
	$AnimationTree.set("parameters/AttentionB/blend_amount", a[1])
	$AnimationTree.set("parameters/AttentionC/blend_amount", a[2])
	$AnimationTree.set("parameters/TimeScale/scale", 1.0 + attention + r * 0.2)
	
	$AnimationTree.set("parameters/Cheer/blend_amount", cheer)
	$AnimationTree.set("parameters/Clap/blend_amount", clap)
	$AnimationTree.set("parameters/Tired/blend_amount", tired)
	$AnimationTree.set("parameters/Anger/blend_amount", anger)

func _physics_process(delta: float) -> void:
	var cr = transform.basis.get_rotation_quaternion()
	if has_node("Armature"):
		$Armature.position = $AnimationTree.get_root_motion_position_accumulator()
