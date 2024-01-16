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
	var x_pos_in_command := 1
	var y_pos_in_command := 2
	var width_pos_in_command := 999999
	var height_pos_in_command := 999999

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
	
	var initbang = N.new()
	initbang.title = "initbang"
	initbang.outputs.push_front(C.new("value", "bang"))
	db["initbang"] = initbang
	
	var div = N.new()
	div.title = "/"
	div.inputs.push_front(C.new("value", "float"))
	div.inputs.push_front(C.new("by", "float"))
	div.outputs.push_front(C.new("output", "float"))
	db["/"] = div
	
	var div_signal = N.new()
	div_signal.title = "/~"
	div_signal.inputs.push_front(C.new("value", "float"))
	div_signal.inputs.push_front(C.new("by", "float"))
	div_signal.outputs.push_front(C.new("output", "float"))
	db["/~"] = div_signal
	
	var multiply = N.new()
	multiply.title = "*"
	multiply.inputs.push_front(C.new("value", "float"))
	multiply.inputs.push_front(C.new("by", "float"))
	multiply.outputs.push_front(C.new("output", "float"))
	db["*"] = multiply
	
	var abs = N.new()
	abs.title = "abs"
	abs.inputs.push_front(C.new("value", "float"))
	abs.outputs.push_front(C.new("output", "float"))
	db["abs"] = abs
	
	var multiply_signal = N.new()
	multiply_signal.title = "*~"
	multiply_signal.inputs.push_front(C.new("value", "signal"))
	multiply_signal.inputs.push_front(C.new("by", "float"))
	multiply_signal.outputs.push_front(C.new("output", "signal"))
	db["*~"] = multiply_signal

	var add = N.new()
	add.title = "+"
	add.inputs.push_front(C.new("value", "signal"))
	add.inputs.push_front(C.new("by", "float"))
	add.outputs.push_front(C.new("output", "signal"))
	db["+"] = add

	var add_signal = N.new()
	add_signal.title = "+~"
	add_signal.inputs.push_front(C.new("value", "signal"))
	add_signal.inputs.push_front(C.new("by", "float"))
	add_signal.outputs.push_front(C.new("output", "signal"))
	db["+~"] = add_signal
	
	var integer = N.new()
	integer.title = "int"
	integer.inputs.push_front(C.new("value", "bang"))
	integer.inputs.push_front(C.new("set", "any"))
	integer.outputs.push_front(C.new("output", "int"))
	db["int"] = integer

	var bang = N.new()
	bang.title = "bng"
	bang.inputs.push_front(C.new("value", "any"))
	bang.outputs.push_front(C.new("value", "bang"))
	bang.visible_in_subpatch = true
	bang.specialized = preload("res://addons/libpd/script/objects/special/bang_node.tscn")
	bang.default_args = ['obj', '{x}', '{y}', '{obj}', "15", "250", "50", "0", 'empty', 'empty', 'empty', "17", "7", "0", "10", '#fcfcfc', '#000000', '#000000']
	db["bang"] = bang
	db["bng"] = bang
	
	var toggle = N.new()
	toggle.title = "tgl"
	toggle.inputs.push_front(C.new("value", "any"))
	toggle.outputs.push_front(C.new("value", "any"))
	toggle.visible_in_subpatch = true
	toggle.specialized = preload("res://addons/libpd/script/objects/special/toggle_node.tscn")
	toggle.default_args = ['obj', '{x}', '{y}', '{obj}', "8", "0", '{s}', '{r}', 'empty', "17", "7", "0", "10", '#fcfcfc', '#000000', '#000000', '0', '1']
	db["toggle"] = toggle
	db["tgl"] = toggle

	var hsl = N.new()
	hsl.title = "hsl"
	hsl.inputs.push_front(C.new("value", "float"))
	hsl.outputs.push_front(C.new("value", "float"))
	hsl.visible_in_subpatch = true
	hsl.specialized = preload("res://addons/libpd/script/objects/special/hsl.tscn")
	hsl.default_args = ['obj', '{x}', '{y}', '{obj}', '128', '15', '0', '127', '0', '0', '{s}', '{r}', 'empty', '-2', '-3', '0', '12', '-262144', '-1', '-1', '0', '1']
	db["hslider"] = hsl
	db["hsl"] = hsl

	var msg = N.new()
	msg.title = "msg"
	msg.inputs.push_front(C.new("input", "bang"))
	msg.outputs.push_front(C.new("output", "any"))
	msg.default_args = ["msg", "{x}", "{y}", ""]
	msg.specialized = preload("res://addons/libpd/script/objects/special/message.tscn")
	db["msg"] = msg
	db["message"] = msg
	
	var mtof = N.new()
	mtof.title = "mtof"
	mtof.inputs.push_front(C.new("midi", "float"))
	mtof.outputs.push_front(C.new("freq", "float"))
	db["mtof"] = mtof

	var metro = N.new()
	metro.title = "metro"
	metro.inputs.push_front(C.new("playing", "any"))
	metro.inputs.push_front(C.new("time", "float"))
	metro.outputs.push_front(C.new("value", "bang"))
	db["metro"] = metro
	
	var vcf = N.new()
	vcf.title = "vcf~"
	vcf.inputs.push_front(C.new("input", "signal"))
	vcf.inputs.push_front(C.new("freq", "float or signal"))
	vcf.inputs.push_front(C.new("q", "float"))
	vcf.outputs.push_front(C.new("real", "signal"))
	vcf.outputs.push_front(C.new("imaginary", "signal"))
	db["vcf~"] = vcf
	
	var print = N.new()
	print.title = "print"
	print.inputs.push_front(C.new("input", "any"))
	db["print"] = print
	
	var random = N.new()
	random.title = "random"
	random.inputs.push_front(C.new("input", "bang"))
	random.inputs.push_front(C.new("range", "any"))
	random.outputs.push_front(C.new("random", "int"))
	db["random"] = random
	
	var line = N.new()
	line.title = "line"
	line.inputs.push_front(C.new("input", "signal"))
	line.inputs.push_front(C.new("freq", "float or signal"))
	line.inputs.push_front(C.new("q", "float"))
	line.outputs.push_front(C.new("real", "signal"))
	line.outputs.push_front(C.new("imaginary", "signal"))
	db["line"] = line
	
	var line_signal = N.new()
	line_signal.title = "line~"
	line_signal.inputs.push_front(C.new("input", "signal"))
	line_signal.inputs.push_front(C.new("q", "float"))
	line_signal.outputs.push_front(C.new("real", "signal"))
	line_signal.outputs.push_front(C.new("imaginary", "signal"))
	db["line~"] = line_signal
	
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
	floatatom.specialized = preload("res://addons/libpd/script/objects/special/float_node.tscn")
	db["floatatom"] = floatatom

	var receive = N.new()
	receive.title = "r"
	receive.outputs.push_front(C.new("value", "signal or float"))
	db["receive"] = receive
	db["r"] = receive

	var receive_signal = N.new()
	receive_signal.title = "r~"
	receive_signal.outputs.push_front(C.new("value", "signal or float"))
	db["receive~"] = receive_signal
	db["r~"] = receive_signal
	
	var send = N.new()
	send.title = "s"
	send.inputs.push_front(C.new("value", "signal or float"))
	db["s"] = send
	db["send"] = send
	
	var send_signal = N.new()
	send_signal.title = "s~"
	send_signal.inputs.push_front(C.new("value", "signal"))
	db["s~"] = send_signal
	db["send~"] = send_signal
	
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
	coords.specialized = preload("res://addons/libpd/script/objects/special/coords.tscn")
	coords.resizeable = true
	coords.visible_in_subpatch = true
	coords.default_args = ['coords', '0', '-1', '1', '1', '100', '100', '2', '{x}', '{y}']
	coords.width_pos_in_command = 5
	coords.height_pos_in_command = 6
	coords.x_pos_in_command = 8
	coords.y_pos_in_command = 9
	db["coords"] = coords

	var sel = N.new()
	sel.title = "sel"
	sel.inputs.push_front(C.new("lhs", "any"))
	sel.inputs.push_front(C.new("rhs", "any"))
	sel.outputs.push_front(C.new("match", "bang"))
	sel.outputs.push_front(C.new("else", "any"))
	db["select"] = sel
	db["sel"] = sel
	
	var nbx = N.new()
	nbx.title = "nbx"
	nbx.inputs.push_front(C.new("input", "float"))
	nbx.outputs.push_front(C.new("output", "float"))
	nbx.default_args = ['obj', '{x}', '{y}', '{obj}', '2', '14', '-1e+37', '1e+37', '0', '0', 'empty', 'empty', 'empty', '0', '-8', '0', '10']
	nbx.specialized = preload("res://addons/libpd/script/objects/special/float_node.tscn")
	nbx.visible_in_subpatch = true
	db["nbx"] = nbx

	var mod = N.new()
	mod.title = "%"
	mod.inputs.push_front(C.new("input", "float"))
	mod.inputs.push_front(C.new("input", "float"))
	mod.outputs.push_front(C.new("output", "float"))
	db["%"] = mod
	
	var expr = N.new()
	expr.title = "expr"
	expr.inputs.push_front(C.new("input", "args"))
	expr.outputs.push_front(C.new("output", "result"))
	db["expr"] = expr

	
	var snapshot_signal = N.new()
	snapshot_signal.title = "snapshot~"
	snapshot_signal.inputs.push_front(C.new("input", "signal"))
	snapshot_signal.outputs.push_front(C.new("output", "float"))
	db["snapshot~"] = snapshot_signal


	var array = N.new()
	array.title = "array"
	array.default_args = ['array', 'soundData', '100', 'float', '3']
	array.x_pos_in_command = 999999
	array.y_pos_in_command = 999999
	db["array"] = array
	
	var tarbread4_signal = N.new()
	tarbread4_signal.title = "tabread4~"
	tarbread4_signal.inputs.push_front(C.new("input", "signal"))
	tarbread4_signal.inputs.push_front(C.new("idk", "idk"))
	tarbread4_signal.outputs.push_front(C.new("output", "signal"))
	db["tabread4~"] = tarbread4_signal

	var readsf_signal = N.new()
	readsf_signal.title = "readsf~"
	readsf_signal.inputs.push_front(C.new("path", "list"))
	readsf_signal.outputs.push_front(C.new("out", "signal"))
	readsf_signal.outputs.push_front(C.new("done", "bang"))
	db["readsf~"] = readsf_signal
	
	var soundfiler = N.new()
	soundfiler.title = "soundfiler"
	soundfiler.inputs.push_front(C.new("msg", "msg"))
	soundfiler.outputs.push_front(C.new("samples", "float"))
	db["soundfiler"] = soundfiler
	
	var delay = N.new()
	delay.title = "delay"
	delay.inputs.push_front(C.new("start", "bang"))
	delay.inputs.push_front(C.new("delay time", "float"))
	delay.outputs.push_front(C.new("timeout", "bang"))
	db["del"] = delay
	db["delay"] = delay

func get_node_model(subpatch_name:String):
	var node_model = NodeDb.db.get(subpatch_name)
	if node_model:
		return node_model
		
	var subpatch_path = "res://junk/".path_join(subpatch_name + ".pd")
	if FileAccess.file_exists(subpatch_path):
		var subpatch = load("res://addons/libpd/script/objects/patch.tscn").instantiate()
		subpatch.open(subpatch_path)
		return NodeDb.db.get(subpatch_name)
		
	return null
