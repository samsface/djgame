extends PDSpecial

func _ready() -> void:
	PureData.bind(get_sender_id_())
	PureData.float.connect(_float)

func _pd_init() -> void:
	if not parent.canvas.is_done:
		await parent.canvas.done

	add_ghost_rs_()
