extends RefCounted
class_name GraphControlNodeDatabase

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

func _init():
	var loadbang = N.new()
	loadbang.title = "loadbang"
	loadbang.outputs.push_front(C.new("value", "bang"))
	db["loadbang"] = loadbang

	var giada = N.new()
	giada.title = "giada"
	giada.inputs.push_front(C.new("value", "bang"))
	giada.outputs.push_front(C.new("value", "bang"))
	db["giada"] = giada
	
	var reply = N.new()
	reply.title = "reply"
	reply.inputs.push_front(C.new("value", "bang"))
	reply.outputs.push_front(C.new("value", "bang"))
	db["reply"] = reply


func add(node_name:String, special) -> void:
	var n = N.new()
	n.title = node_name
	n.specialized = special
	db[node_name] = n

func get_node_model(subpatch_name:String) -> N:
	var node_model = db.get(subpatch_name)
	if node_model:
		return node_model

	return null

func found_(command:String, pos:Vector2) -> String:
	var aaa = command.split(' ')
	
	var nm = db.get(aaa[0])
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
