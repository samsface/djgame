extends GDExample

var regex = RegEx.new()
var sanitize = RegEx.new()

var open_patches_ := {}

var files := {}

func _ready() -> void:

	regex.compile("^[+-]?\\d+(\\.\\d+)?$")
	
	print(is_initialized())
	stream = AudioStreamGenerator.new()
	stream.buffer_length = 0.1
	playing = true
	
	#print(open_patch("maker_test.pd"))
	
	#start_message(0)
	#finish_message("pd-maker_test.pd", "clear")
	
	set_process(true)


class IteratePackedStringArray:
	var packed_string_:PackedStringArray
	var i = 0
	
	func _init(args:String = "") -> void:
		if args.is_empty():
			return
		packed_string_ = args.split(' ')
	
	func next():
		if i >= packed_string_.size():
			return null
		
		i += 1
		
		return packed_string_[i-1]
		
	func next_as_int():
		if i >= packed_string_.size():
			return null
		
		i += 1
		
		if packed_string_[i-1] == null:
			return 0

		return int(packed_string_[i-1])
		
	func join(join_string:String = " ") -> String:
		return join_string.join(packed_string_.slice(i-1))
