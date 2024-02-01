extends Node3D

@onready var looking_at_ := $toykit

var patch_file_handle_ := PDPatchFile.new()
var tween_:Tween

func _ready() -> void:
	Engine.max_fps = 144

	Camera.smooth_look_at($toykit)
	
	var p = ProjectSettings.globalize_path("res://junk/xxx.pd")

	if not patch_file_handle_.open(p):
		push_error("couldn't open patch")
		
	for node in get_children():
		if node is Device:
			node.value_changed.connect(value_changed_.bind(node))

	PureData.bind("s-clock")
	PureData.bind("s-rumble")
	PureData.bang.connect(_bang)

var i_ = 0

func _bang(r):
	if r == "s-clock":
		i_ += 1
		#if i_ % 2 == 0:
		#	Camera.smooth_look_at(looking_at_, true)
		return
	elif r == "s-rumble":
		Camera.shake(0.7, 0.001)

func value_changed_(value, node:Device) -> void:
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("noise"):
		print("r-" + name + "-noise")
		PureData.send_bang("r-" + name + "-noise")
