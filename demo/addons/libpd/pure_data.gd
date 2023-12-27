extends GDExample

var regex = RegEx.new()

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
