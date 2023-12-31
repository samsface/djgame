extends Control
class_name PDSpecial

var setting_selfs_value_ := false
var tween_:Tween

var parent : 
	set(value):
		pass
	get:
		return get_parent().get_parent().get_parent()

func _ready() -> void:
	pass

func get_id_() -> String:
	var id := []
	
	var p = get_parent()
	while p:
		if p is PDNode:
			id.push_front(p.index)
		elif p is PDPatch:
			id.push_front("$1")
		p = p.get_parent()

	return '/'.join(id)

func get_receiver_id_() -> String:
	return '/r/' + get_id_()

func get_sender_id_() -> String:
	return '/s/' + get_id_()

func _connection(to:PDSlot):
	pass

func add_ghost_rs_() -> void:
	if not parent.canvas:
		return

	var receiver_args = ["obj", str(parent.position.x), str(parent.position.y - 30), "r", '/r/%s/%s' % ["$1", parent.index]]
	var receiver_node = preload("res://objects/graph_node.tscn").instantiate()
	receiver_node.canvas = parent.canvas
	receiver_node.text = ' '.join(receiver_args)
	receiver_node.visible = false
	parent.canvas.add_child(receiver_node)
	parent.ghost_rs.push_back(receiver_node)

	var sender_args = ["obj", str(parent.position.x), str(parent.position.y + 30), "s", '/s/%s/%s' % ["$1", parent.index]]
	var sender_node = preload("res://objects/graph_node.tscn").instantiate()
	sender_node.canvas = parent.canvas
	sender_node.text = ' '.join(sender_args)
	sender_node.visible = false
	parent.canvas.add_child(sender_node)
	parent.ghost_rs.push_back(sender_node)

	var receiver_cable = preload("res://objects/cable.tscn").instantiate()
	receiver_cable.from = receiver_node.get_outlet(0)
	receiver_cable.to = parent.get_inlet(0)
	parent.canvas.add_child(receiver_cable)

	var sender_cable = preload("res://objects/cable.tscn").instantiate()
	sender_cable.from = parent.get_outlet(0)
	sender_cable.to = sender_node.get_inlet(0)
	parent.canvas.add_child(sender_cable)
	



func _pd_init() -> void:
	if not parent.canvas.is_loading:
		await parent.canvas.loading_done
	elif not parent.is_inside_tree():
		await parent.ready

	add_ghost_rs_()

func animate_(sustain:float = 0.5, attack:float = 0.1, decay:float = 0.1) -> void:
	if tween_:
		if tween_.is_running() and tween_.get_total_elapsed_time() < sustain:
			return
		
		tween_.kill()

	tween_ = create_tween()
	tween_.tween_property(self, "modulate", Color.ORANGE, attack)
	tween_.tween_property(self, "modulate", Color.WHITE, decay).set_delay(sustain)

func _value_changed(value) -> void:
	if setting_selfs_value_:
		return

	PureData.send_float(get_receiver_id_(), value)

func _float(receiver:String, new_value:float) -> void:
	if receiver == get_sender_id_():
		animate_()
		setting_selfs_value_ = true
		set("value", new_value)
		setting_selfs_value_ = false

func set_play_mode(value:bool) -> void:
	pass
