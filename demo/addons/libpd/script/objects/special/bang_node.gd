extends PDSpecial

func _ready() -> void:
	PureData.bind(get_sender_id_())
	PureData.bang.connect(_bang)

func _button_down() -> void:
	PureData.send_bang(get_receiver_id_())

func _bang(receiver:String) -> void:
	if receiver == get_sender_id_():
		animate_(0.1, 0.0, 0.0)
