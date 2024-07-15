@tool
extends MarginContainer

var apps_ := []

@export var device_width:Vector2 :
	set(value):
		device_width = value
		%MarginContainer.custom_minimum_size = device_width

func start_app(app:Control) -> void:
	if apps_.has(app):
		return

	for a in apps_:
		if a.get_parent():
			a.get_parent().remove_child(a)
		
	apps_.push_back(app)

	app.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	app.size_flags_vertical = Control.SIZE_EXPAND_FILL
	%App.get_parent().add_child(app)
