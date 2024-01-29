extends Node3D

@onready var looking_at_ := $toykit

var patch_file_handle_ := PDPatchFile.new()
var tween_:Tween

func _ready() -> void:
	look_at_($toykit)
	
	var p = ProjectSettings.globalize_path("res://junk/xxx.pd")

	if not patch_file_handle_.open(p):
		push_error("couldn't open patch")
		
	for node in get_children():
		if node is Device:
			node.value_changed.connect(value_changed_)

func value_changed_(nob:NobMapping, value) -> void:
	PureData.write_at_array_index(nob.name, nob.index, value)

func send_message_(args):
	PureData.send_message("pd-xxx", args)

func send_float_(receiver:String, value:float, ns:String):
	print("r-%s-%s" % [ns, receiver])
	PureData.send_float("r-%s-%s" % [ns, receiver], value)

func send_array_(receiver:String, value:float, ns:String):
	print("r-%s-%s" % [ns, receiver])
	PureData.write_at_array_index("toykit-array1", 0, 1)

func look_at_(node) -> void:
	if tween_:
		tween_.kill()
		
	looking_at_ = node
	
	var r = $Camera3D.rotation
	var p = $Camera3D.position
	
	var x = looking_at_.position.x + randf_range(-1, 1) * 0.05
	
	$Camera3D.position.x = x
	$Camera3D.look_at(looking_at_.position)
	var t = $Camera3D.rotation
	$Camera3D.position = p
	$Camera3D.rotation = r

	tween_ = create_tween()
	tween_.set_trans(Tween.TRANS_SINE)
	tween_.set_ease(Tween.EASE_OUT)
	tween_.set_parallel()
	tween_.tween_property($Camera3D, "position:x", x, 0.6)
	tween_.tween_property($Camera3D, "rotation", t, 0.6)
	tween_.tween_property($Camera3D, "fov", randf_range(50, 75), 0.6)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("look"):
		if looking_at_ == $toykit:
			look_at_($hat)
		else:
			look_at_($toykit)
