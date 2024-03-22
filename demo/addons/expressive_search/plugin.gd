extends EditorPlugin

func ting():
	var ei := get_editor_interface()
	var cp := ei.get_command_palette()
	cp.add_command("exp-search", "exp-search", search_)

func search_() -> void:
	pass
