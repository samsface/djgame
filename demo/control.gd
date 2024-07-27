@tool
extends CodeEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	var s = EditorInterface.get_script_editor().get_current_editor().get_base_editor().syntax_highlighter
	print(s)
	syntax_highlighter = s


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
