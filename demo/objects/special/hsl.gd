extends PDSpecial

func _ready() -> void:
	PureData.bind(get_sender_id_())
	PureData.float.connect(_float)

func _float(receiver:String, value:float) -> void:
	return
	if receiver == get_sender_id_():
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.RED, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _value_changed(value: float) -> void:
	PureData.send_float(get_receiver_id_(), value)
	print(value)
