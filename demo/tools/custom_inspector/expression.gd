extends InspectorControl

func set_value(v):
	%Value/CodeEdit.text = v

func _ready():
	%Value/CodeEdit.text_changed.connect(func(): value_changed.emit(%Value/CodeEdit.text))

func get_control() -> Control:
	return %Value
