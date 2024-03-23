extends GDExample

var regex = RegEx.new()
var sanitize = RegEx.new()

var open_patches_ := {}

var files := {}

func _ready() -> void:

	regex.compile("^[+-]?\\d+(\\.\\d+)?$")
	
	print(is_initialized())
	stream = AudioStreamGenerator.new()
	stream.buffer_length = 0.034
	playing = true

	set_process(true)

class IteratePackedStringArray:
	var packed_string_:PackedStringArray
	var i = 0
	
	func _init(args:String = "") -> void:
		if args.is_empty():
			return
		
		args = args.replace(', ', ' , ')
			
		packed_string_ = args.split(' ')
	
	func next():
		if i >= packed_string_.size():
			return null
		
		i += 1
		
		return packed_string_[i-1]
		
	func next_as_int():
		if i >= packed_string_.size():
			return 0
		
		i += 1
		
		if packed_string_[i-1] == null:
			return 0

		return int(packed_string_[i-1])
		
	func join(join_string:String = " ") -> String:
		if i >= packed_string_.size():
			return ""

		return join_string.join(packed_string_.slice(i-1))
	
	func sneak(p) -> void:
		packed_string_[i] = str(p)

func found_(command:String, pos:Vector2) -> String:
	var aaa = command.split(' ')
	
	var nm = NodeDb.db.get(aaa[0])
	if not nm:
		return ""

	var tpl = ' '.join(nm.default_args)
	if tpl.is_empty():
		tpl = 'obj {x} {y} {obj}'

	var res = tpl.format({ x=int(pos.x), y=int(pos.y), obj=nm.title})
	
	var args = ' '.join(aaa.slice(1))
	if not args.is_empty():
		res += " " + args

	return res

func send_message(canvas, args) -> void:
	PureData.start_message(args.size())

	for i in range(1, args.size()):
		if PureData.regex.search(str(args[i])):
			PureData.add_float(float(args[i]))
		else:
			PureData.add_symbol(args[i])

	PureData.finish_message(canvas, args[0])

func write_at_array_index(array:String, index:int, value:float) -> void:
	PureData.write_array(array, index, PackedFloat32Array([value]), 1)
