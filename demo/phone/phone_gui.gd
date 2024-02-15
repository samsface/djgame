@tool
extends MarginContainer

@export var device_width:Vector2 :
	set(value):
		device_width = value
		%MarginContainer.custom_minimum_size = device_width

func start_app(app:Control) -> void:
	app.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	app.size_flags_vertical = Control.SIZE_EXPAND_FILL
	%App.get_parent().add_child(app)
