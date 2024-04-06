@tool
extends Resource
class_name LineStyle

@export_range(0.0, 1.0) var line_width:float :
	set(v):
		line_width = v
		emit_changed()
@export_range(0, 100) var fill_line_count:int :
	set(v):
		fill_line_count = v
		emit_changed()
@export_range(0.0, 1.0) var fill_line_width:float :
	set(v):
		fill_line_width = v
		emit_changed()
@export_range(0, 100) var fill_line_accent:int :
	set(v):
		fill_line_accent = v
		emit_changed()
@export_range(0.0, 1.0) var fill_line_accent_width:float :
	set(v):
		fill_line_accent_width = v
		emit_changed()
