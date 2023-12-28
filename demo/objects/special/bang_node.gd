extends Button

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

func _ready() -> void:
	PureData.bind(get_sender_id_())
	PureData.bang.connect(_bang)

func _button_down() -> void:
	print(get_receiver_id_())
	PureData.send_bang(get_receiver_id_())

func _bang(receiver:String) -> void:
	if receiver == get_sender_id_():
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.RED, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _connection(to:PDSlot):
	pass
