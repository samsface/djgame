extends PDSpecial

func _ready() -> void:
	PureData.bind(get_sender_id_())
	PureData.bang.connect(_bang)

func _button_down() -> void:
	PureData.send_bang(get_receiver_id_())

func _bang(receiver:String) -> void:
	if receiver == get_sender_id_():
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.RED, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.1)
