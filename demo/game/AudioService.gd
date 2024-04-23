extends Node
class_name AudioService

var patch_file_handle_ := PDPatchFile.new()

var bang_signals_ := {}
var float_signals_ := {}

func _ready() -> void:
	Bus.audio_service = self
	
	var p = ProjectSettings.globalize_path("res://junk/xxx.pd")

	if not patch_file_handle_.open(p):
		push_error("couldn't open patch")

	PureData.bang.connect(_bang)
	PureData.float.connect(_float)

func _bang(signal_name:String) -> void:
	var callback = bang_signals_.get(signal_name)
	if callback:
		callback.call()

func _float(signal_name:String, value:float) -> void:
	var callback = float_signals_.get(signal_name)
	if callback:
		callback.call(value)

func set_metro(value:float) -> void:
	PureData.metro = value
	emit_float("metro", value)

func play() -> void:
	emit_bang("PLAY")

func stop() -> void:
	PureData.send_bang("r-STOP")
	PureData.send_bang("r-RESET")

func connect_to_bang(signal_name:StringName, callable:Callable) -> void:
	PureData.bind("s-" + signal_name)
	bang_signals_["s-" + signal_name] = callable

func connect_to_float(signal_name:StringName, callable:Callable) -> void:
	PureData.bind("s-" + signal_name)
	float_signals_["s-" + signal_name] = callable

func emit_bang(signal_name:StringName) -> void:
	PureData.send_bang("r-" + signal_name)

func emit_float(signal_name:StringName, v:float) -> void:
	PureData.send_float("r-" + signal_name, v)

func _exit_tree() -> void:
	patch_file_handle_.close()
