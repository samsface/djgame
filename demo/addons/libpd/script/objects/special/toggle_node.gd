extends PDSpecial

func _ready() -> void:
	PureData.bind(get_sender_id_())
	PureData.float.connect(_float)
	modulate = Color.RED

func _float(receiver:String, value:float) -> void:
	if receiver == get_sender_id_():
		animate_(0.1)

		if value:
			set("text", "ON")
			modulate = Color.GREEN
		else:
			set("text", "OFF")
			modulate = Color.RED

func _pressed() -> void:
	var id = get_receiver_id_()
	print(id)
	PureData.send_bang(id)
