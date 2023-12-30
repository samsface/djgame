extends PDSpecial

func _ready() -> void:
	super._ready()
	PureData.bind(get_sender_id_())
	PureData.float.connect(_float)

