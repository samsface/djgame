extends PDSpecial

func _ready() -> void:
	PureData.bind(get_sender_id_())
	PureData.float.connect(_float)

func _float(receiver:String, value:float) -> void:
	if receiver == get_sender_id_():
		animate_(0.1)

		if value:
			set("text", "ON")
		else:
			set("text", "OFF")

func _pressed() -> void:
	PureData.send_bang(get_receiver_id_())
