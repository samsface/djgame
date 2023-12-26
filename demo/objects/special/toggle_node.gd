extends Button

var receiver_name_ := ""
var sender_name_ := ""

@export var parent:Node :
	set(value):
		pass
	get:
		return get_parent().get_parent().get_parent().get_parent().get_parent()

func _ready() -> void:
	await get_tree().process_frame

	if not receiver_name_:
		receiver_name_ = "_" + str(randi())
		var index = PureData.create_obj(parent.canvas, "r " + receiver_name_)
		PureData.create_connection(parent.canvas, index, 0, index -1, 0)
		PureData.bind(receiver_name_)

	if not sender_name_:
		sender_name_ = "_" + str(randi())
		var index = PureData.create_obj(parent.canvas, "s " + sender_name_)
		PureData.create_connection(parent.canvas, index - 2, 0, index, 0)
		PureData.bind(sender_name_)

	PureData.float.connect(_float)

func _float(receiver:String, value:float) -> void:
	if receiver == sender_name_:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.RED, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.1)
		
		if value:
			text = "ON"
		else:
			text = "OFF"

func _pressed() -> void:
	PureData.send_bang(receiver_name_)
	print(self, "sam")

func _connection(to) -> void:
	pass
