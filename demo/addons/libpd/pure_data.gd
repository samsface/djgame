extends GDExample

var regex_ = RegEx.new()

var open_patches_ := {}

func _ready() -> void:
	regex_.compile("^[0-9]+")
	
	print(is_initialized())
	stream = AudioStreamGenerator.new()
	stream.buffer_length = 0.1
	playing = true
	
	#print(open_patch("maker_test.pd"))
	
	#start_message(0)
	#finish_message("pd-maker_test.pd", "clear")
	
	set_process(true)

func create_obj(canvas:String, message:String, pos:Vector2 = Vector2.ZERO) -> int:
	if not canvas:
		push_error("no canvas")
		return -1
	
	var args = message.split(' ')
	
	var obj = NodeDb.db.get(args[0])
	if not obj:
		return -1

	if args[0] == "bang":
		args[0] = "bng"

	start_message(args.size() + 2)
	
	add_float(pos.x)
	add_float(pos.y)

	for arg in args:
		if regex_.search(arg):
			add_float(float(arg))
		else:
			add_symbol(arg)

	if args[0] == "floatatom":
		finish_message(canvas, "floatatom")
	else:
		finish_message(canvas, "obj")

	if not open_patches_.has(canvas):
		open_patches_[canvas] = 0

	open_patches_[canvas] += 1

	return open_patches_[canvas] -1

func create_connection(canvas:String, from_object_idx, from_slot_idx, to_object_idx, to_object_slot_idx):
	PureData.start_message(4)
	PureData.add_float(from_object_idx)
	PureData.add_float(from_slot_idx)
	PureData.add_float(to_object_idx)
	PureData.add_float(to_object_slot_idx)
	PureData.finish_message(canvas, "connect")

func send_disconnect(canvas:String, from_object_idx, from_slot_idx, to_object_idx, to_object_slot_idx):
	PureData.start_message(4)
	PureData.add_float(from_object_idx)
	PureData.add_float(from_slot_idx)
	PureData.add_float(to_object_idx)
	PureData.add_float(to_object_slot_idx)
	PureData.finish_message(canvas, "disconnect")

func save(canvas:String) -> void:
	PureData.start_message(0)
	PureData.finish_message(canvas, "menusave")
