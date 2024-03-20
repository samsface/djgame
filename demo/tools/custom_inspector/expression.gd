extends VBoxContainer

signal  value_changed

@export var value:String :
	set(v):
		$Value/CodeEdit.text = v
	get:
		return $Value/CodeEdit.text 

func _ready():
	$Value/CodeEdit.text_changed.connect(func(): value_changed.emit($Value/CodeEdit.text))

func get_control() -> Control:
	return $Value
