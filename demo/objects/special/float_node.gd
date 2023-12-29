extends PDSpecial

var setting_selfs_value_ := false

func _ready() -> void:
	PureData.bind(get_sender_id_())
	PureData.float.connect(_float)

func _float(receiver:String, new_value:float) -> void:
	print(receiver)
	if receiver == get_sender_id_():
		if get("value") != new_value:
			setting_selfs_value_ = true
			set("value", new_value)
			setting_selfs_value_ = false

func _value_changed(value: float) -> void:
	print(get_sender_id_())
	if setting_selfs_value_:
		return
	
	PureData.send_float(get_receiver_id_(), value)

func _pd_init() -> void:
	if not parent.canvas.is_done:
		await parent.canvas.done

	add_ghost_rs_()
	
