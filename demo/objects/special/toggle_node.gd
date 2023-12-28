extends PDSpecial

func _ready() -> void:
	PureData.bind(get_sender_id_())
	PureData.float.connect(_float)

func _float(receiver:String, value:float) -> void:
	if receiver == get_sender_id_():
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.RED, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.1)
		
		if value:
			set("text", "ON")
		else:
			set("text", "OFF")

func _pressed() -> void:
	PureData.send_bang(get_receiver_id_())
