extends LineEdit

var index := 0
var receiver_name_ := ""

@export var parent:Node :
	set(value):
		pass
	get:
		return get_parent().get_parent().get_parent().get_parent().get_parent()


func _ready() -> void:
	receiver_name_ = "a" + str(randi())
	index = PureData.create_obj(parent.canvas, "r " + receiver_name_)
	PureData.create_connection(parent.canvas, index, 0, index -1, 0)


func _on_text_changed(new_text: String) -> void:
	PureData.send_float(receiver_name_, float(new_text))
