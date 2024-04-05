@tool
extends Resource
class_name LineStyle

@export_range(0.0, 1.0) var line_width:float :
	set(v):
		line_width = v
		emit_changed()
@export_range(0.0, 1.0) var fill_line_width:float :
	set(v):
		fill_line_width = v
		emit_changed()
@export_range(0.0, 1.0) var fill_line_spacing:float :
	set(v):
		fill_line_spacing = v
		emit_changed()
