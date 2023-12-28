extends Node

class N:
	var title := ""
	var inputs := []
	var outputs := []
	var comment := ""
	var visible_in_subpatch := false
	var specialized:PackedScene
	var instance := false
	var default_args := PackedStringArray()
	var resizeable := false

class C:
	var title := ""
	var type := ""
	var comment := ""
	
	func _init(title, type, comment = "") -> void:
		self.title = title
		self.type = type
		self.comment = comment

var db := {}

func _enter_tree() -> void:
	var loadbang = N.new()
	loadbang.title = "loadbang"
	loadbang.outputs.push_front(C.new("value", "bang"))
	db["loadbang"] = loadbang
	
	var multiply = N.new()
	multiply.title = "*"
	multiply.inputs.push_front(C.new("value", "float"))
	multiply.inputs.push_front(C.new("by", "float"))
	multiply.outputs.push_front(C.new("output", "float"))
	db["*"] = multiply
	
	var multiply_signal = N.new()
	multiply_signal.title = "*~"
	multiply_signal.inputs.push_front(C.new("value", "signal"))
	multiply_signal.inputs.push_front(C.new("by", "float"))
	multiply_signal.outputs.push_front(C.new("output", "signal"))
	db["*~"] = multiply_signal

	var multiply_add = N.new()
	multiply_add.title = "*~"
	multiply_add.inputs.push_front(C.new("value", "signal"))
	multiply_add.inputs.push_front(C.new("by", "float"))
	multiply_add.outputs.push_front(C.new("output", "signal"))
	db["+~"] = multiply_add

	var bang = N.new()
	bang.title = "bng"
	bang.inputs.push_front(C.new("value", "any"))
	bang.outputs.push_front(C.new("value", "bang"))
	bang.visible_in_subpatch = true
	bang.specialized = preload("res://objects/special/bang_node.tscn")
	bang.default_args = ['obj', '{x}', '{y}', '{obj}', "15", "250", "50", "0", '{s}', '{r}', 'empty', "17", "7", "0", "10", '#fcfcfc', '#000000', '#000000']
	db["bang"] = bang
	db["bng"] = bang
	
	var toggle = N.new()
	toggle.title = "tgl"
	toggle.inputs.push_front(C.new("value", "any"))
	toggle.outputs.push_front(C.new("value", "any"))
	toggle.visible_in_subpatch = true
	toggle.specialized = preload("res://objects/special/toggle_node.tscn")
	toggle.default_args = ['obj', '{x}', '{y}', '{obj}', "8", "0", '{s}', '{r}', 'empty', "17", "7", "0", "10", '#fcfcfc', '#000000', '#000000', '0', '1']
	db["tgl"] = toggle
	
	var metro = N.new()
	metro.title = "metro"
	metro.inputs.push_front(C.new("playing", "any"))
	metro.inputs.push_front(C.new("time", "float"))
	metro.outputs.push_front(C.new("value", "bang"))
	db["metro"] = metro
	
	var osc = N.new()
	osc.title = "osc~"
	osc.inputs.push_front(C.new("frequency", "float or signal"))
	osc.inputs.push_front(C.new("phase", "float"))
	osc.outputs.push_front(C.new("wave", "signal"))
	db["osc~"] = osc
	
	var phasor = N.new()
	phasor.title = "phasor~"
	phasor.inputs.push_front(C.new("frequency", "float or signal"))
	phasor.inputs.push_front(C.new("phase", "float"))
	phasor.outputs.push_front(C.new("wave", "signal"))
	db["phasor~"] = phasor

	var dac = N.new()
	dac.title = "dac~"
	dac.inputs.push_front(C.new("left channel", "signal"))
	dac.inputs.push_front(C.new("right channel", "signal"))
	db["dac~"] = dac
	
	var floatatom = N.new()
	floatatom.title = "floatatom"
	floatatom.inputs.push_front(C.new("value", "float"))
	floatatom.outputs.push_front(C.new("value", "float"))
	floatatom.default_args = ["floatatom", "0", "100", "5", "0", "0", "0", "", "-", "-", "-"]
	db["floatatom"] = floatatom
	
	var receiver = N.new()
	receiver.title = "r"
	receiver.outputs.push_front(C.new("value", "signal or float"))
	db["r"] = receiver
	
	var send = N.new()
	send.title = "s"
	send.inputs.push_front(C.new("value", "signal or float"))
	db["s"] = send
	
	var clip = N.new()
	clip.title = "clip~"
	clip.inputs.push_front(C.new("input", "signal"))
	clip.inputs.push_front(C.new("min", "float"))
	clip.inputs.push_front(C.new("max", "float"))
	clip.outputs.push_front(C.new("output", "signal"))
	db["clip~"] = clip
	
	var outlet = N.new()
	outlet.title = "outlet"
	outlet.inputs.push_front(C.new("output", "any"))
	db["outlet"] = outlet
	
	var outlet_signal = N.new()
	outlet_signal.title = "outlet~"
	outlet_signal.inputs.push_front(C.new("output", "signal"))
	db["outlet~"] = outlet_signal
	
	var inlet = N.new()
	inlet.title = "inlet"
	inlet.outputs.push_front(C.new("input", "any"))
	db["inlet"] = inlet
	
	var spigot = N.new()
	spigot.title = "spigot"
	spigot.inputs.push_front(C.new("input", "signal"))
	spigot.inputs.push_front(C.new("block", "float"))
	spigot.outputs.push_front(C.new("output", "signal"))
	db["spigot"] = spigot

	var coords = N.new()
	coords.title = "coords"
	coords.specialized = preload("res://objects/special/coords.tscn")
	coords.resizeable = true
	coords.visible_in_subpatch = true
	db["coords"] = coords
	
	var sel = N.new()
	sel.title = "sel"
	sel.inputs.push_front(C.new("lhs", "any"))
	sel.inputs.push_front(C.new("rhs", "any"))
	sel.outputs.push_front(C.new("match", "bang"))
	sel.outputs.push_front(C.new("else", "any"))
	db["select"] = metro
	db["sel"] = metro
	
	var nbx = N.new()
	nbx.title = "nbx"
	nbx.inputs.push_front(C.new("input", "float"))
	nbx.outputs.push_front(C.new("output", "float"))
	db["nbx"] = nbx


	var msg = N.new()
	msg.title = "msg"
	msg.inputs.push_front(C.new("input", "bang"))
	msg.outputs.push_front(C.new("output", "any"))
	db["msg"] = msg
	
	var mod = N.new()
	mod.title = "%"
	mod.inputs.push_front(C.new("input", "float"))
	mod.outputs.push_front(C.new("output", "float"))
	db["%"] = mod
