extends Node

signal clock_changed

var patch_file_handle_ := PureDataPatch.new()
var audio_stream_:PureDataAudioStreamPlayer

var bang_signals_ := {}
var float_signals_ := {}
var metro := 130
var latency := 0.2
var regex_ = RegEx.new()

var clock_ := 0
var clock:int :
	set(v):
		clock_ = v
		emit_float("CLOCK", clock_)
	get:
		return clock_

func _ready() -> void:
	regex_.compile("^[+-]?\\d+(\\.\\d+)?$")
	
	Bus.audio_service = self

	audio_stream_ = PureDataAudioStreamPlayer.new()
	audio_stream_.bus = "Music"
	audio_stream_.stream = AudioStreamGenerator.new()
	audio_stream_.stream.buffer_length = 0.024
	add_child(audio_stream_)
	audio_stream_.play()

	print_debug("libpd init was ", audio_stream_.is_initialized())

	var p = ProjectSettings.globalize_path("res://junk/radio#####.pd")

	if not patch_file_handle_.open(p):
		push_error("couldn't open patch")

	audio_stream_.bang.connect(_bang)
	audio_stream_.float.connect(_float)
	
	Bus.audio_service.connect_to_float("clock", _clock)
	
	#audio_stream_.stop()
	
func _bang(signal_name:String) -> void:
	var callback = bang_signals_.get(signal_name)
	if callback:
		callback.call()

func _float(signal_name:String, value:float) -> void:
	var callback = float_signals_.get(signal_name)
	if callback:
		callback.call(value)

func set_metro(value:float) -> void:
	metro = value
	emit_float("metro", value)

func play() -> void:
	emit_float("WIPE-BUFFER", 1)
	emit_bang("PLAY")

func pause() -> void:
	audio_stream_.send_bang("r-STOP")
	
func stop() -> void:
	audio_stream_.send_bang("r-STOP")
	audio_stream_.send_bang("r-RESET")

func connect_to_bang(signal_name:StringName, callable:Callable) -> void:
	audio_stream_.bind("s-" + signal_name)
	bang_signals_["s-" + signal_name] = callable

func connect_to_float(signal_name:StringName, callable:Callable) -> void:
	audio_stream_.bind("s-" + signal_name)
	float_signals_["s-" + signal_name] = callable

func emit_bang(signal_name:StringName) -> void:
	audio_stream_.send_bang("r-" + signal_name)

func emit_float(signal_name:StringName, v:float) -> void:
	audio_stream_.send_float("r-" + signal_name, v)

func emit_message(signal_name, args:Array) -> void:
	audio_stream_.start_message(args.size())

	for i in range(1, args.size()):
		if regex_.search(str(args[i])):
			audio_stream_.add_float(float(args[i]))
		else:
			audio_stream_.add_symbol(args[i])

	audio_stream_.finish_message(signal_name, args[0])

func _exit_tree() -> void:
	patch_file_handle_.close()

func write_at_array_index(array:String, index:int, value:float) -> void:
	audio_stream_.write_array(array, index, PackedFloat32Array([value]), 1)

func _clock(value) -> void:
	clock_ = value
	clock_changed.emit(clock_)
