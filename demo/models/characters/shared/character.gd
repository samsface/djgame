@tool
extends Node3D
class_name Character

var r := randf()

@export_range(0.0, 3.0) var time_scale:float  = 1.0 :
	set(v):
		time_scale = v
		if is_node_ready():
			$AnimationTree.set("parameters/TimeScale/scale", v)
	
@export_range(0.0, 1.0) var talking:float :
	set(v):
		talking = v
		if is_node_ready():
			$AnimationTree.set("parameters/TalkingGate/blend_amount", ceil(talking))
			$AnimationTree.set("parameters/Talking/blend_position", v)

@export_range(0.0, 1.0) var anger:float :
	set(v):
		if anger == 0 and v != 0:
			$AnimationTree.set("parameters/AngerTimeSeek/seek_request", randf() * 19.0)
		anger = v

@export_range(0.0, 1.0) var jump:float :
	set(v):
		jump = v
		if is_node_ready():
			$AnimationTree.set("parameters/Jump/blend_position", jump)

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
		
@export var emotion:CharacterFace.Emotion :
	set(v):
		if emotion != v:
			emotion = v
			%Face.emotion = v

func _ready():
	$Armature/Skeleton3D/Face.get_surface_override_material(0).set_shader_parameter("texture_face", $SubViewport.get_texture())

func _physics_process(delta: float) -> void:
	if has_node("Armature"):
		$Armature.position = $AnimationTree.get_root_motion_position_accumulator()
