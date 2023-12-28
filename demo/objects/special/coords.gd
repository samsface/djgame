extends ReferenceRect

func _ready():
	get_parent().get_parent().get_parent().z_index -=1
	#PureData.start_message(9)
	#PureData.add_float(x_from)
	#PureData.add_float(x_to)
	#PureData.add_float(y_from)
	#PureData.add_float(y_to)
	#PureData.add_float(width)
	#PureData.add_float(height)
	#PureData.add_float(graph_on_parent)
	#PureData.add_float(x)
	#PureData.add_float(y)
	#PureData.finish_message(canvas, "coords")
