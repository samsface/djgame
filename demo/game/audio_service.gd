extends Node
class_name AudioService

var patch_file_handle_ := PureDataPatch.new()
var audio_stream_:PureDataAudioStreamPlayer

var bang_signals_ := {}
var float_signals_ := {}
var metro := 130
var latency := 0.25

func _ready() -> void:
	Bus.audio_service = self
	
	audio_stream_ = PureDataAudioStreamPlayer.new()
	audio_stream_.stream = AudioStreamGenerator.new()
	audio_stream_.stream.buffer_length = 0.024
	add_child(audio_stream_)
	audio_stream_.play()

	print_debug("Pure is ", audio_stream_.is_initialized())

	var p = ProjectSettings.globalize_path("res://junk/xxx.pd")

	if not patch_file_handle_.open(p):
		push_error("couldn't open patch")

	audio_stream_.bang.connect(_bang)
	audio_stream_.float.connect(_float)

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
	emit_float("CLOCK", -16)
	emit_bang("PLAY")
	
func stop() -> void:
	audio_stream_.send_bang("r-STOP")
	audio_stream_.send_bang("r-RESET")
	emit_float("CLOCK", -16)

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

func _exit_tree() -> void:
	patch_file_handle_.close()

func write_at_array_index(array:String, index:int, value:float) -> void:
	audio_stream_.write_array(array, index, PackedFloat32Array([value]), 1)

var clock := 0
