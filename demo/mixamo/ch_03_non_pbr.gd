@tool
extends Node3D

var r := randf()

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

func _ready() -> void:
	pass

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
