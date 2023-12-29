extends PDSpecial

func _ready() -> void:
	PureData.bind(get_sender_id_())
	PureData.float.connect(_float)
